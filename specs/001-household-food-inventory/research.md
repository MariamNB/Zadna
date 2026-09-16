# Research: Household Food Inventory

**Date**: 2026-09-13
**Feature**: 001-household-food-inventory

## Technical Decisions

### 1. Language: Python 3.12

**Decision**: Python 3.12

**Rationale**:
- FastAPI ecosystem is Python-native and mature
- Excellent Unicode handling (critical for Arabic/English mixed text)
- Rich async support for high-throughput API
- Strong typing with Pydantic 2.x
- Wide deployment options (containers, serverless, VMs)
- 3.12 has better performance and typing features than 3.11

**Alternatives considered**:
- **Python 3.11**: Stable but older; 3.12 is current stable with better performance
- **Node.js/TypeScript**: Good Unicode, but FastAPI's automatic OpenAPI generation and Pydantic validation are superior for contract-first development
- **Go**: Excellent performance, but Unicode handling more verbose; less mature ecosystem for rapid API development

---

### 2. Framework: FastAPI 0.115.x

**Decision**: FastAPI (current stable)

**Rationale**:
- Automatic OpenAPI 3.1 schema generation (contract-first)
- Pydantic 2.x integration for request/response validation
- Native async support with Starlette
- Dependency injection system for auth, DB, services
- Built-in test client for integration testing
- Production-ready (used by Netflix, Uber, Microsoft)

**Alternatives considered**:
- **Django REST Framework**: Heavier, synchronous-first, less flexible OpenAPI
- **Flask**: Requires more manual setup for validation, OpenAPI, async
- **Starlette alone**: Too low-level; FastAPI adds exactly what's needed

---

### 3. Database: PostgreSQL 16 with SQLAlchemy 2.0 ORM (async)

**Decision**: PostgreSQL + SQLAlchemy 2.0 (async)

**Rationale**:
- Mature, reliable, ACID-compliant
- Excellent Unicode support (UTF-8 native)
- JSONB for flexible audit log metadata
- Row-level security potential for future multi-tenant
- SQLAlchemy 2.0: modern async API, improved typing, no legacy query API
- Alembic for versioned migrations

**Alternatives considered**:
- **SQLite**: Not production-ready for concurrent writes
- **MongoDB**: No schema enforcement; reference data needs relational integrity
- **MySQL**: Weaker JSON support; less mature async drivers

---

### 4. Authentication: JWT (RS256) via PyJWT + Argon2 via pwdlib

**Decision**: PyJWT for tokens, pwdlib[argon2] for password hashing

**Rationale**:
- **PyJWT**: Actively maintained, pure Python, supports RS256/ES256, no transitive crypto dependencies
- **pwdlib[argon2]**: Modern wrapper around argon2-cffi; Argon2id is the recommended password hash (OWASP, NIST)
- Short-lived access tokens (15 min) + rotating refresh tokens (30 days)
- Stateless: scales horizontally, no session store
- RS256: public/private key separation; rotation without invalidating all tokens
- Refresh token rotation: limits blast radius of token theft
- Explicit token lifecycle documented in `auth/schemas.py` and `auth/service.py`

**Security Model Documentation**:
- Access tokens: JWT RS256, 15 min expiry, `sub` = user_id, `household_id` claim for quick scoping
- Refresh tokens: Opaque random tokens, stored hashed in DB, 30 day expiry, rotation on use
- Password hashing: Argon2id (memory-hard, side-channel resistant)
- Token revocation: Refresh token deletion on logout/password change; access token blocklist optional for sensitive ops
- HTTPS required in production; secure cookies optional for web clients

**Alternatives considered**:
- **python-jose**: Less actively maintained; extra dependencies
- **passlib[bcrypt]**: bcrypt is acceptable but Argon2id is stronger and modern standard
- **Session cookies**: Requires Redis/sticky sessions; CSRF protection complexity
- **API keys**: No built-in expiry/rotation; less standard for user-facing apps

---

### 5. Project Structure: Feature-oriented modular monolith

**Decision**: `backend/src/app/{auth,households,inventory,storage,reference,audit,common}/`

**Rationale**:
- Clear separation: each feature owns its models, schemas, service, router
- Scales to multiple features without monolith bloat
- Matches domain-driven design principles
- Tests mirror source structure
- Alembic at repo root for migration management
- Easy to extract a feature into a separate service later if needed

**Alternatives considered**:
- **Flat `models/schemas/api/services` (Option 1)**: Too flat for growing API surface
- **Monorepo with frontend**: Frontend not in scope; separate repo preferred
- **Microservices**: Premature for MVP; modular monolith is correct starting point

---

### 6. Reference Data Modeling: Global categories/units, household-owned storage locations

**Decision**: 
- **Categories, Units**: Global reference tables with `key` (stable ID) + `labels` JSONB (`{"ar": "...", "en": "..."}`)
- **Storage Locations**: Household-owned hierarchical table with `parent_id` self-reference

**Rationale**:
- `key` = stable machine identifier (never changes)
- `labels` JSONB: add languages without schema migration (FR-009)
- Storage locations: household-specific because every household organizes differently; hierarchical with `parent_id` for arbitrary nesting (FR-010)
- Seeded via Alembic migration (idempotent upsert for global; household locations created by users)

**Alternatives considered**:
- **ENUM types**: Not extensible without migration; no localization
- **Single `reference_data` table with `type` column**: Less type-safe, harder FK constraints
- **Hardcoded in code**: Violates FR-009 (extensible without code change)
- **Global storage locations**: Doesn't match real usage; households have different freezer layouts

---

### 7. Pagination: Real cursor-based pagination from v1

**Decision**: Cursor-based pagination with opaque base64 tokens; `limit` + `cursor` params; envelope `{items, next_page_token}`

**Rationale**:
- Satisfies FR-029 envelope shape
- Stable ordering: `(created_at, id)` for deterministic cursor
- Works correctly with concurrent writes (no skipped/duplicate items)
- No breaking change when clients adopt pagination
- Enforced max page size (100) for API protection

**Alternatives considered**:
- **Offset/limit**: Leaks implementation; unstable with concurrent writes; O(n) performance
- **Envelope with `next_page_token: null` always (fake pagination)**: Deceptive; clients can't test pagination logic; violates "real from v1" requirement
- **Link headers (RFC 5988)**: Less discoverable; envelope is more explicit

---

### 8. Unicode Handling: NFC for search/comparison; original stored byte-exact

**Decision**: Store as `TEXT` (PostgreSQL UTF-8); apply NFC normalization only for search/indexing; original text preserved

**Rationale**:
- PostgreSQL `TEXT` stores UTF-8 byte-exact
- FastAPI/Pydantic passes Unicode through unchanged
- Reject invalid UTF-8 at boundary
- NFC normalization for search: `WHERE normalized_name = NFC($1)` alongside original column
- No `NFD` or custom normalization — user bytes preserved in primary column
- Test corpus: 20+ Arabic strings with diacritics, tatweel, mixed digits, mixed-script

**Alternatives considered**:
- **No normalization**: Search won't match canonically equivalent strings
- **Normalize to NFC in place**: Violates FR-025 (must not mutate original)
- **Store as BYTEA**: Overcomplicates; TEXT is correct for text

---

### 9. Hard Delete with Transactional Audit Log

**Decision**: `DELETE` removes row; audit record written in same transaction via service layer (not trigger)

**Rationale**:
- FR-018: explicit delete only
- FR-020: audit log with snapshot (JSONB), actor, household, timestamp
- Service-layer transaction: audit + delete atomic; no trigger magic; easier to test
- No soft-delete flag (FR-019)
- Audit model: `audit_logs` with `action`, `entity_type`, `entity_id`, `metadata` JSONB

**Alternatives considered**:
- **PostgreSQL trigger**: Harder to test; couples audit to DB; service layer is explicit
- **Application-level audit without transaction**: Risk of missed writes on crash
- **Soft delete (`deleted_at`)**: Violates FR-019 (no background purge, but flag remains)

---

### 10. Cross-Household Access: 404 Not Found

**Decision**: All authorization failures return 404 (not 403)

**Rationale**:
- FR-023: prevent enumeration attacks
- Consistent with "not found" semantics
- Logging (FR-024) captures actual intent for security monitoring
- Implemented via `get_current_household_id` dependency + scoped queries

**Alternatives considered**:
- **403 Forbidden**: Reveals resource exists
- **401 Unauthorized**: Only for missing/invalid auth, not authorization

---

### 11. Household Membership Model: Proper multi-user from start

**Decision**: `users`, `households`, `household_members` with roles (`owner`, `admin`, `member`)

**Rationale**:
- Spec FR-027: auto-provision household on first request
- But model must support multiple users per household (future family sharing)
- Roles enable future permission granularity
- Bootstrap: new user → create household + membership (role=owner) in same transaction
- No invitation API in v1; model ready for it

**Alternatives considered**:
- **Single-user households**: Requires schema migration later; violates "no permanent limitation"
- **No roles**: Can't distinguish owner/admin/member for future features

---

### 12. Inventory Item Model: Renamed to `InventoryItem` with extended fields

**Decision**: Entity named `InventoryItem` (not `FoodItem`) with fields for future expiry/thawing features

**Rationale**:
- "FoodItem" implies product catalog; "InventoryItem" = household's instance/batch
- Extended fields: `prepared_at`, `frozen_at`, `opened_at`, `expires_at`, `is_homemade`, `status`
- Supports homemade frozen foods: marinated chicken, meatballs, stuffed vegetables, sauces, dough, ready-to-cook meals
- Not a full batch/lot system; just enough metadata for future features

**Alternatives considered**:
- **Minimal `FoodItem`**: Would require migration for expiry/thawing features
- **Full batch/lot tracking**: Over-engineered for MVP

---

### 13. Testing Strategy: Three-layer with security focus

**Decision**: Contract (schemathesis) + Integration (testcontainers) + Unit (pytest-mock) + Security (explicit cross-household tests)

| Layer | Tool | Scope |
|-------|------|-------|
| Contract | schemathesis | OpenAPI spec compliance |
| Integration | pytest + testcontainers (PostgreSQL) | Full HTTP → DB flows, household isolation |
| Unit | pytest + pytest-mock | Services, utils, auth logic, pagination |
| Security | pytest fixtures | Cross-household 404, enumeration prevention |

**Rationale**:
- Contract tests: catch breaking API changes automatically
- Integration tests: real DB, real HTTP, real auth — high confidence
- Testcontainers: disposable PostgreSQL per test run; no shared test DB
- Security tests: explicit fixtures for multi-household scenarios

---

### 14. Configuration: pydantic-settings with `.env`

**Decision**: `Settings` class with `SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")`

**Rationale**:
- Type-safe configuration with validation
- `.env` for local dev; environment variables in prod
- Secrets never in code

---

### 15. Dependency Management: `uv` with locked versions

**Decision**: Use `uv` for dependency management; `pyproject.toml` + `uv.lock`

**Rationale**:
- Fast, reliable, reproducible installs
- Lockfile ensures exact versions in CI/production
- No `>=` ranges for reproducibility

---

### 16. Redis: Documented as future dependency

**Decision**: Not in MVP; documented for caching, rate limiting, background jobs, real-time sync

**Rationale**:
- No MVP feature requires Redis
- Adding it prematurely adds operational complexity
- Will be introduced when rate limiting, background workers, or websockets are needed

---

### 17. Background Jobs: Documented future architecture

**Decision**: Not in MVP; document architecture for expiry reminders, thawing reminders, shopping reminders

**Rationale**:
- No current spec requires scheduled jobs
- When needed: `taskiq` or `arq` (lightweight, Redis-backed) rather than Celery
- Keep HTTP requests fast; offload slow work

---

### 18. AI: Explicitly outside inventory core

**Decision**: No AI infrastructure in this feature

**Rationale**:
- Inventory API must be deterministic and reliable
- Future AI layer calls well-defined inventory API
- Never allow LLM direct database access

---

## Open Questions for Implementation

1. **Timezone for `date_added` default**: Spec says "household's configured timezone". No household config in v1. → Use UTC for v1; add `timezone` column to `households` table in later feature.

2. **Notes length limit**: Spec says "target: 500 characters" (Assumption). → Set 500 in Pydantic validation; document in OpenAPI.

3. **JWT key management**: Where to store private key? → File path via env var for MVP; rotate via deployment.

4. **Rate limiting**: Not in spec. → Add `slowapi` middleware as hardening when Redis added.

5. **API versioning in URL**: `/api/v1/...` → Yes, standard practice.

6. **Refresh token storage**: Store hash (Argon2) in DB; rotate on use.

7. **Password reset flow**: Not in spec. → Document as future; stub endpoint returning 501.

8. **Email verification**: Not in spec. → Document as future; stub endpoint returning 501.

---

## Next Steps

1. Generate `data-model.md` with entity definitions, relationships, constraints, indexes
2. Generate `contracts/openapi.yaml` from spec requirements (auth, CRUD, pagination, filtering, 404 behavior)
3. Generate `contracts/reference-data.json` with seeded global categories/units
4. Generate `quickstart.md` for local development
5. Run `/speckit-tasks` to create implementation task list