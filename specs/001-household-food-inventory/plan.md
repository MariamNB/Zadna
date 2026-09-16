# Implementation Plan: Household Food Inventory

**Branch**: `001-household-food-inventory` | **Date**: 2026-09-13 | **Spec**: specs/001-household-food-inventory/spec.md

**Input**: Feature specification from `/specs/001-household-food-inventory/spec.md`

## Summary

Build a REST API for household food inventory management. The MVP allows authenticated users to add, list, filter, edit, and delete food inventory items with Arabic/English support. Auto-provisions one household per user on first request. Uses PostgreSQL for persistence, FastAPI for the API layer, and JWT (PyJWT) + Argon2 for authentication. Implements proper household membership model from the start to support future family sharing. Real cursor-based pagination from v1. Hierarchical household-specific storage locations. Transactional audit logging for hard deletes.

## Technical Context

**Language/Version**: Python 3.12

**Primary Dependencies** (pinned in `pyproject.toml` with `uv` lockfile):
- FastAPI 0.115.x
- SQLAlchemy 2.0.36+
- Pydantic 2.10+
- Pydantic Settings 2.6+
- PyJWT 2.10+
- pwdlib[argon2] 1.0+
- asyncpg 0.29+
- alembic 1.13+
- pytest 8.3+
- pytest-asyncio 0.24+
- httpx 0.28+
- testcontainers 4.8+
- schemathesis 3.18+
- uvicorn 0.32+
- python-multipart 0.0.12+

**Storage**: PostgreSQL 16 (primary), with SQLAlchemy 2.0 async ORM. Reference data (categories, units) seeded via migrations. Storage locations are household-owned hierarchical configuration.

**Testing**: pytest with pytest-asyncio. Contract tests with schemathesis against OpenAPI spec. Integration tests with testcontainers-postgresql. Unit tests with pytest-mock. Security tests for household isolation.

**Target Platform**: Linux server (containerized deployment)

**Project Type**: Web service (REST API) — modular monolith

**Performance Goals** (server/API processing, measured under test environment with realistic DB sizes, excluding network/AI latency):
- Add item: <150ms p95
- Edit/Delete item: <150ms p95
- Filter inventory: <300ms p95
- List 200 items (paginated): <500ms p95

**Constraints**:
- All user-visible text must support Unicode correctly; Arabic, English, and mixed text must round-trip without character loss
- PostgreSQL uses UTF-8; NFC normalization applied for search/comparison only; original text stored byte-exact
- Authentication required on every endpoint
- Cross-household access returns 404 (not 403) to prevent enumeration
- Hard delete with transactional audit log (same transaction)
- Real cursor-based pagination from v1 with deterministic ordering
- Reference data (categories, units) global; storage locations household-owned
- Household membership model supports multiple users, roles (owner/admin/member), extensible for invitations

**Scale/Scope**:
- MVP: ~100 households, ~10k items
- Future target: ~10k households, ~2M items
- Architecture: modular monolith (FastAPI + PostgreSQL); Redis/background workers only when justified

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Status**: `constitution.md` currently contains only placeholder content with no enforceable project principles.

**Action**: No formal "PASS" can be claimed based on assumed principles. Standard engineering practices (test-first, modular design, security boundaries, observability) are adopted as **proposed implementation practices**, not constitutional requirements. This check will be re-run once `constitution.md` contains actual ratified principles.

## Project Structure

### Documentation (this feature)

```text
specs/001-household-food-inventory/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── openapi.yaml
│   └── reference-data.json
└── tasks.md             # Phase 2 output (/speckit-tasks command)
```

### Source Code (repository root)

```text
backend/
├── src/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                 # FastAPI app factory
│   │   ├── config.py               # Settings via pydantic-settings
│   │   ├── database.py             # SQLAlchemy engine/session
│   │   ├── common/                 # Shared utilities, base classes
│   │   │   ├── __init__.py
│   │   │   ├── base_model.py       # SQLAlchemy declarative base + mixins
│   │   │   ├── pagination.py       # Cursor pagination logic
│   │   │   ├── unicode.py          # Unicode normalization utilities
│   │   │   └── exceptions.py       # Custom exceptions
│   │   ├── auth/                   # Authentication & authorization
│   │   │   ├── __init__.py
│   │   │   ├── jwt.py              # JWT encoding/decoding (PyJWT)
│   │   │   ├── passwords.py        # Argon2 hashing (pwdlib)
│   │   │   ├── dependencies.py     # FastAPI deps: current_user, household
│   │   │   ├── models.py           # User, refresh token models
│   │   │   ├── schemas.py          # Auth request/response schemas
│   │   │   └── service.py          # Auth business logic
│   │   ├── households/             # Household domain
│   │   │   ├── __init__.py
│   │   │   ├── models.py           # Household, HouseholdMember
│   │   │   ├── schemas.py
│   │   │   ├── service.py
│   │   │   └── router.py
│   │   ├── inventory/              # Food inventory domain
│   │   │   ├── __init__.py
│   │   │   ├── models.py           # InventoryItem (renamed from FoodItem)
│   │   │   ├── schemas.py
│   │   │   ├── service.py
│   │   │   └── router.py
│   │   ├── storage/                # Storage locations domain
│   │   │   ├── __init__.py
│   │   │   ├── models.py           # StorageLocation (hierarchical)
│   │   │   ├── schemas.py
│   │   │   ├── service.py
│   │   │   └── router.py
│   │   ├── reference/              # Global reference data
│   │   │   ├── __init__.py
│   │   │   ├── models.py           # Category, Unit
│   │   │   ├── schemas.py
│   │   │   ├── service.py
│   │   │   └── router.py
│   │   └── audit/                  # Audit logging
│   │       ├── __init__.py
│   │       ├── models.py           # AuditLog
│   │       ├── service.py
│   │       └── router.py           # (admin/internal only)
│   └── tests/
│       ├── __init__.py
│       ├── conftest.py             # Shared fixtures
│       ├── contract/
│       │   ├── __init__.py
│       │   └── test_openapi.py
│       ├── integration/
│       │   ├── __init__.py
│       │   ├── conftest.py
│       │   ├── test_auth.py
│       │   ├── test_households.py
│       │   ├── test_inventory.py
│       │   ├── test_storage.py
│       │   ├── test_reference.py
│       │   └── test_security.py    # Cross-household isolation
│       └── unit/
│           ├── __init__.py
│           ├── test_auth_service.py
│           ├── test_inventory_service.py
│           ├── test_storage_service.py
│           ├── test_pagination.py
│           └── test_unicode.py
├── alembic/
│   ├── env.py
│   ├── script.py.mako
│   └── versions/
├── pyproject.toml
├── uv.lock                         # Locked dependencies
├── Dockerfile
├── docker-compose.yml
├── docker-compose.test.yml         # For testcontainers CI
└── .env.example
```

**Structure Decision**: Feature-oriented structure (`app/auth`, `app/households`, `app/inventory`, `app/storage`, `app/reference`, `app/audit`, `app/common`). Each feature contains its own router, service, schemas, models. Shared code in `common/`. This provides good maintainability for MVP while keeping extraction paths clean for future features.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Service layer (not generic repository) | Domain rules in services; SQLAlchemy directly in services; testable with mocked session | Generic repository adds indirection without benefit; SQLAlchemy is already a repository |
| Feature-oriented modules | Clear ownership boundaries; scales to family sharing, expiry, shopping features | Flat `models/schemas/api/services` becomes unmanageable at ~10 features |
| Hierarchical storage locations | Household-specific freezer organization; FR-010 requires parent-child schema | Global flat locations don't match real household usage |
| Cursor pagination from v1 | Mobile client needs stable paging; offset breaks with concurrent writes | Offset pagination fails correctness at scale; envelope reserved but empty is deception |
| Household membership from start | Spec FR-022/FR-023 require household-scoped auth; "1 user = 1 household" is temporary bootstrap | Hardcoding single-user households requires schema migration later |
| Transactional audit log | FR-020 requires audit on every delete; async audit can lose records | Separate async process risks missing audit entries on crash |