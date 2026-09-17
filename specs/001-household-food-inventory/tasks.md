---

description: "Task list for Household Food Inventory feature implementation"
---

# Tasks: Household Food Inventory

**Input**: Design documents from `/specs/001-household-food-inventory/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are OPTIONAL - only include them if explicitly requested in the feature specification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- Paths shown below assume single project - adjust based on plan.md structure

---

## Phase 1: Setup (Minimal Project Bootstrap)

**Purpose**: Get a runnable FastAPI project with database

- [X] T001 Create backend project structure per implementation plan (`backend/src/app/`, `backend/alembic/`, `backend/tests/`)
- [X] T002 Initialize Python 3.12 project with core dependencies in `backend/pyproject.toml` (FastAPI 0.115.x, SQLAlchemy 2.0.36+, Pydantic 2.10+, PyJWT 2.10+, pwdlib[argon2] 1.0+, asyncpg 0.29+, alembic 1.13+, uvicorn 0.32+, python-multipart 0.0.12+)
- [X] T003 [P] Create Docker configuration (`backend/Dockerfile`, `backend/docker-compose.yml`, `backend/.env.example`)
- [X] T004 [P] Create `backend/src/app/config.py` with Settings (DATABASE_URL, JWT_PRIVATE_KEY_PATH, JWT_PUBLIC_KEY_PATH, JWT_ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES, REFRESH_TOKEN_EXPIRE_DAYS, APP_HOST, APP_PORT, LOG_LEVEL, MAX_PAGE_SIZE)
- [X] T005 [P] Generate JWT RS256 keys for development (`backend/keys/private.pem`, `backend/keys/public.pem`)
- [X] T006 Create SQLAlchemy base and mixins in `backend/src/app/common/base_model.py` (Base, TimestampMixin, UUIDMixin)
- [X] T007 Create database engine/session in `backend/src/app/database.py` (async engine, async session factory, get_db dependency)
- [X] T008 Create FastAPI app factory in `backend/src/app/main.py` (CORS, exception handlers, router inclusion, health endpoint)
- [X] T009 Create Alembic environment in `backend/alembic/env.py` and `backend/alembic/script.py.mako`

---

## Phase 2: Auth + Database + Household (Core Auth Flow)

**Purpose**: Register/login works, household auto-provisioned on first request

- [X] T010 Create initial migration: all tables in `backend/alembic/versions/001_initial_schema.py` (users, households, household_members, inventory_items, storage_locations, categories, units, audit_logs per data-model.md)
- [X] T011 Create seed migration: global reference data (categories, units) in `backend/alembic/versions/002_seed_reference_data.py` (per data-model.md seed data with Arabic/English labels)
- [X] T012 Create auth models in `backend/src/app/auth/models.py` (User: UUID PK, email UNIQUE, password_hash Argon2id, is_active, email_verified, created_at, updated_at; RefreshToken: hashed token, user_id FK, expires_at, revoked_at)
- [X] T013 Create password hashing in `backend/src/app/auth/passwords.py` (Argon2id via pwdlib)
- [X] T014 Create JWT handling in `backend/src/app/auth/jwt.py` (RS256 encode/decode, access token 15 min with household_id claim, refresh token opaque)
- [X] T015 Create auth schemas in `backend/src/app/auth/schemas.py` (RegisterRequest, LoginRequest, TokenResponse, RefreshRequest)
- [X] T016 Create auth service in `backend/src/app/auth/service.py` (register, login, refresh, logout; password reset stubs returning 501)
- [X] T017 Create auth dependencies in `backend/src/app/auth/dependencies.py` (get_current_user, get_current_household_id, get_current_household_member_id - return 401 on invalid auth, 404 on cross-household access per FR-023)
- [X] T018 Create auth router in `backend/src/app/auth/router.py` (POST /auth/register, POST /auth/login, POST /auth/token, POST /auth/refresh, POST /auth/logout)
- [X] T019 Create household models in `backend/src/app/households/models.py` (Household: UUID PK, name, timezone DEFAULT 'UTC'; HouseholdMember: UUID PK, household_id FK, user_id FK, role CHECK IN ('owner','admin','member'), joined_at, unique (household_id, user_id))
- [X] T020 Create bootstrap function `create_household_for_user(user_id)` in `backend/src/app/households/service.py` (creates household + membership role=owner + default storage locations Fridge/Freezer/Pantry in single transaction)
- [X] T021 Create household schemas in `backend/src/app/households/schemas.py` (HouseholdResponse, HouseholdMemberResponse)
- [X] T022 Create household service in `backend/src/app/households/service.py` (get_household, list_members, auto-provision on first request via dependency)
- [X] T023 Create household router in `backend/src/app/households/router.py` (GET /household, GET /household/members)
- [X] T024 Create conftest.py with shared fixtures in `backend/src/tests/conftest.py` (async client, db session, auth headers, test user, test household)
- [X] T025 [P] Add Unicode handling utilities in `backend/src/app/common/unicode.py` (NFC normalization for search, byte-exact preservation)
- [X] T026 [P] Add cursor pagination utilities in `backend/src/app/common/pagination.py` (opaque base64 tokens, stable ordering, max page size 100)
- [X] T027 [P] Add custom exceptions in `backend/src/app/common/exceptions.py` (NotFoundError, ValidationError, AuthorizationError, ConflictError)
- [X] T028 [P] Add auth failure logging in `backend/src/app/auth/dependencies.py` (log rejected authorization attempts with acting user, target identifier, timestamp, request kind per FR-024; exclude user content from logs)

---

## Phase 3: Storage Locations (Minimal for Inventory)

**Purpose**: Household has Fridge/Freezer/Pantry so inventory items can reference them

- [X] T029 Add storage_locations table to migration `backend/alembic/versions/003_storage_locations.py` (StorageLocation: UUID PK, household_id FK, parent_id FK self-ref, name, type CHECK IN ('fridge','freezer','pantry','garage_freezer','drawer','shelf','section','other'), sort_order, created_by FK, updated_by FK)
- [X] T030 Create storage location model in `backend/src/app/storage/models.py` (StorageLocation per data-model.md)
- [X] T031 Create storage location schemas in `backend/src/app/storage/schemas.py` (StorageLocationResponse - read-only for MVP)
- [X] T032 Create storage location service in `backend/src/app/storage/service.py` (list top-level locations for household, get by ID - household scoped)
- [X] T033 Create storage location router in `backend/src/app/storage/router.py` (GET /storage-locations?parent_id=null, GET /storage-locations/{id})

---

## Phase 4: US1 - Add & View Inventory (Priority: P1) 🎯 MVP FIRST WORKING SCREEN

**Goal**: Authenticated user adds food item, sees it in inventory list with all fields preserved byte-exact (Arabic/English/mixed)

**Independent Test**: Single authenticated user adds one food item with Arabic name, retrieves inventory list; item appears with every field entered, preserved byte-exact.

### Tests for US1 (OPTIONAL)

- [X] T030 [P] [US1] Integration test: register → login → add item with Arabic name → list returns item byte-exact in `backend/src/tests/integration/test_inventory.py`
- [X] T031 [P] [US1] Integration test: cross-household isolation (User A creates, User B GET by ID returns 404) in `backend/src/tests/integration/test_security.py`
- [X] T032 [P] [US1] Integration test: auto-provision household on first inventory request in `backend/src/tests/integration/test_inventory.py`
- [X] T041 [P] [US1] Create Arabic test corpus in `backend/src/tests/fixtures/arabic_corpus.py` (20+ strings: diacritics "مُبَهَّر", tatweel "فراخ‎‎", mixed Arabic-Indic digits "١.٥ كيلو", mixed-script "Chicken فراخ", long notes >100 chars)
- [X] T042 [P] [US1] Add corpus-driven round-trip test in `backend/src/tests/integration/test_inventory.py` (parametrized test using arabic_corpus.py for add→list→edit→list per SC-004)

### Implementation for US1

- [X] T033 [P] [US1] Create InventoryItem model in `backend/src/app/inventory/models.py` (InventoryItem: UUID PK, household_id FK, name TEXT NOT NULL, name_normalized TEXT NOT NULL (NFC), category_key FK, quantity NUMERIC(10,3) CHECK > 0, unit_key FK, storage_location_id FK, prepared_at DATE NULL, frozen_at DATE NULL, opened_at DATE NULL, expires_at DATE NULL, is_homemade BOOL DEFAULT false, status CHECK IN ('stored','thawing','consumed','discarded') DEFAULT 'stored', date_added DATE DEFAULT CURRENT_DATE, notes TEXT NULL CHECK char_length(notes) <= 500, created_by FK, updated_by FK, created_at, updated_at)
- [X] T034 [P] [US1] Create inventory schemas in `backend/src/app/inventory/schemas.py` (InventoryItemCreate: name 1-255, category_key, quantity > 0, unit_key, storage_location_id UUID, prepared_at/frozen_at/opened_at/expires_at DATE nullable, is_homemade bool, status enum, date_added DATE, notes maxLength 500 nullable; InventoryItemResponse with nested category/unit/storage_location; InventoryItemListResponse envelope {items, next_page_token})
- [X] T035 [US1] Create inventory service create method in `backend/src/app/inventory/service.py` (create_inventory_item: validate category_key exists in categories, unit_key exists in units, storage_location_id belongs to household, quantity > 0, name not empty, notes <= 500 chars; set name_normalized = NFC(name); default date_added = today; created_by/updated_by = current member; return item with nested reference data)
- [X] T039 [P] [US1] Add Unicode preservation verification in `backend/src/app/inventory/service.py` (verify name/notes stored byte-exact, name_normalized = NFC(name) for search only, original never mutated per FR-025)
- [X] T040 [P] [US1] Add silent mutation guard in `backend/src/app/inventory/service.py` (verify no inventory data modified except explicit update/delete per FR-026; audit log captures all mutations)
- [X] T036 [US1] Create inventory service list method in `backend/src/app/inventory/service.py` (list_inventory_items: household-scoped query, cursor pagination (created_at DESC, id), max page size 100, join category/unit/storage_location for labels)
- [X] T037 [US1] Create inventory router in `backend/src/app/inventory/router.py` (POST /inventory-items, GET /inventory-items with limit/cursor, GET /inventory-items/{item_id} household-scoped)
- [X] T038 [P] [US1] Add contract tests with schemathesis in `backend/src/tests/contract/test_openapi.py` (validate Inventory endpoints against OpenAPI spec)
- [X] T043 [US1] Add validation error handling in inventory service (structured ValidationErrorResponse for missing fields, unknown category/unit/storage_location, quantity <= 0, notes > 500)

**Checkpoint**: At this point, user can register → login → see empty inventory → add item with Arabic name → see it in list. **MVP WORKING.**

---

## Phase 5: US2 - Filter Inventory (Priority: P2)

**Goal**: Filter inventory list by category, storage location, or both (AND semantics)

**Independent Test**: With US1 working, populate mixed items and verify filtered queries return correct subset.

### Tests for US2 (OPTIONAL)

- [X] T044 [P] [US2] Integration test: filter by category returns only matching items in `backend/src/tests/integration/test_inventory.py`
- [X] T045 [P] [US2] Integration test: filter by storage_location_id returns only matching items in `backend/src/tests/integration/test_inventory.py`
- [X] T046 [P] [US2] Integration test: combined category + location filter (AND) in `backend/src/tests/integration/test_inventory.py`
- [X] T047 [P] [US2] Integration test: unknown filter key returns empty list not error in `backend/src/tests/integration/test_inventory.py`

### Implementation for US2

- [X] T048 [US2] Enhance inventory service list method in `backend/src/app/inventory/service.py` (add category filter, storage_location_id filter, combined AND semantics, unknown keys return empty list per FR-014, use composite index (household_id, category_key, storage_location_id))
- [X] T049 [US2] Update inventory router GET /inventory-items to accept category and storage_location_id query params in `backend/src/app/inventory/router.py`

**Checkpoint**: User can filter inventory by category and/or storage location.

---

## Phase 6: US3 - Edit Inventory Item (Priority: P3)

**Goal**: Update any field on existing item with validation matching create rules

**Independent Test**: Create item, update every field in turn, confirm changes persist on next read.

### Tests for US3 (OPTIONAL)

- [X] T050 [P] [US3] Integration test: full update (all fields) persists in `backend/src/tests/integration/test_inventory.py`
- [X] T051 [P] [US3] Integration test: partial update (only quantity) leaves other fields unchanged in `backend/src/tests/integration/test_inventory.py`
- [X] T052 [P] [US3] Integration test: cross-household update returns 404, item unchanged in `backend/src/tests/integration/test_security.py`
- [X] T053 [P] [US3] Integration test: quantity <= 0 on update returns validation error, item unchanged in `backend/src/tests/integration/test_inventory.py`

### Implementation for US3

- [X] T054 [US3] Add inventory service update method in `backend/src/app/inventory/service.py` (update_inventory_item: fetch household-scoped, validate provided fields (name not empty, category_key exists, unit_key exists, storage_location_id belongs to household, quantity > 0, notes <= 500, date_added valid date), update name_normalized if name changed, set updated_by/updated_at, return updated item)
- [X] T055 [US3] Add PATCH /inventory-items/{item_id} endpoint in `backend/src/app/inventory/router.py` (calls update service, returns 200 with updated item, 400/422 validation errors, 404 not found/cross-household)

**Checkpoint**: User can edit any field on their inventory items.

---

## Phase 7: US4 - Delete Inventory Item (Priority: P3)

**Goal**: Explicit delete removes item, audit log captured in same transaction

**Independent Test**: Create item, DELETE by ID, verify 204, verify item not in list.

### Tests for US4 (OPTIONAL)

- [X] T056 [P] [US4] Integration test: explicit DELETE removes item, 204 returned in `backend/src/tests/integration/test_inventory.py`
- [X] T057 [P] [US4] Integration test: PATCH with nulled name does NOT delete in `backend/src/tests/integration/test_inventory.py`
- [X] T058 [P] [US4] Integration test: cross-household DELETE returns 404, item remains in `backend/src/tests/integration/test_security.py`
- [X] T059 [P] [US4] Integration test: deleted item GET returns 404 (same as never existed) in `backend/src/tests/integration/test_security.py`
- [X] T060 [P] [US4] Add mutation audit verification in `backend/src/tests/integration/test_audit.py` (verify audit_log entries created for create, update, delete with correct actor/household/item snapshot per FR-020)

### Implementation for US4

- [X] T061 [US4] Create audit log model in `backend/src/app/audit/models.py` (AuditLog per data-model.md)
- [X] T062 [US4] Create audit log service in `backend/src/app/audit/service.py` (log_create, log_update, log_delete - called in same transaction)
- [X] T063 [US4] Add inventory service delete method in `backend/src/app/inventory/service.py` (delete_inventory_item: fetch household-scoped, capture full snapshot, create audit_log entry with action='delete' and metadata=snapshot in SAME TRANSACTION, DELETE row, return 204)
- [X] T064 [US4] Add DELETE /inventory-items/{item_id} endpoint in `backend/src/app/inventory/router.py` (calls delete service, returns 204, 404 not found/cross-household)

**Checkpoint**: All four user stories functional.

---

## Phase 8: Reference Data API (Minimal for Dropdowns)

**Purpose**: Client can fetch categories/units for add/edit forms

- [X] T065 Create reference models in `backend/src/app/reference/models.py` (Category: key PK, labels JSONB (ar, en), sort_order, is_active; Unit: key PK, labels JSONB (ar, en), sort_order, is_active)
- [X] T066 Create reference schemas in `backend/src/app/reference/schemas.py` (Category, Unit, ReferenceDataResponse)
- [X] T067 Create reference service in `backend/src/app/reference/service.py` (get_all_categories, get_all_units, get_reference_data)
- [X] T068 Create reference router in `backend/src/app/reference/router.py` (GET /reference)

---

## Phase 9: Polish & Deferred (Post-MVP)

**Purpose**: Hardening, observability, features not blocking first working screen

- [X] T069 [P] Add unit tests for Unicode handling in `backend/src/tests/unit/test_unicode.py` (20+ Arabic test strings with diacritics, tatweel, mixed digits, mixed-script)
- [X] T070 [P] Add unit tests for pagination in `backend/src/tests/unit/test_pagination.py`
- [X] T071 [P] Add unit tests for auth service in `backend/src/tests/unit/test_auth_service.py`
- [X] T072 [P] Add unit tests for inventory service in `backend/src/tests/unit/test_inventory_service.py`
- [X] T073 [P] Add integration test conftest with testcontainers in `backend/src/tests/integration/conftest.py`
- [X] T074 Run quickstart.md validation: execute all curl commands and verify responses
- [X] T075 Security hardening: verify all endpoints return 404 (not 403) for cross-household access, audit log captures all mutating operations
- [X] T076 [P] Add security coverage verification in `backend/src/tests/integration/test_security_coverage.py` (verify test_security.py covers all endpoints: POST/GET/PATCH/DELETE /inventory-items, GET /inventory-items with filters, GET /storage-locations, GET /reference, GET /household)
- [X] T077 [P] Add coverage threshold check in `backend/pyproject.toml` (pytest-cov --cov-fail-under=100 for security tests)
- [X] T083 [P] Create load test scenario in `backend/src/tests/performance/test_load.py` (5 concurrent users, 20 add-item attempts each, measure p95 <15s per SC-001)
- [X] T084 [P] Create list performance test in `backend/src/tests/performance/test_load.py` (200 items, measure p95 <2s per SC-002)
- [X] T085 [P] Add network condition simulation in `backend/src/tests/performance/conftest.py` (mobile network latency/profile simulation)
- [X] T086 [P] Add performance test runner script in `backend/scripts/run_perf_tests.sh` (executes against testcontainers DB)
- [X] T087 [P] Extend storage locations: POST/PATCH/DELETE endpoints, hierarchical create (nested drawers)
- [X] T088 [P] Household management: invitation API, role management, leave household
- [X] T089 [P] Password reset: implement email flow (currently 501 stubs)
- [X] T090 [P] Audit log router (admin/internal): GET /audit-logs for household
- [X] T091 [P] Email verification flow
- [X] T092 Code cleanup: remove stubs, consistent error handling, address TODOs
- [X] T093 [P] API documentation updates in `backend/docs/`

---

## Dependencies & Execution Order

### Phase Dependencies (Linear MVP Path)

```
Phase 1: Setup
    ↓
Phase 2: Auth + Database + Household (BLOCKS inventory)
    ↓
Phase 3: Storage Locations (BLOCKS inventory add)
    ↓
Phase 4: US1 Add & View Inventory  ← FIRST WORKING SCREEN
    ↓
Phase 5: US2 Filter
    ↓
Phase 6: US3 Edit
    ↓
Phase 7: US4 Delete
    ↓
Phase 8: Reference Data API
    ↓
Phase 9: Polish & Deferred
```

### Parallel Opportunities Within Phases

- Phase 1: T003, T004, T005 run in parallel
- Phase 2: T012-T018 (auth) can parallel T019-T024 (household) after T010-T011 migrations; T025-T028 common utilities in parallel
- Phase 4: T033, T034 run in parallel; T030-T032, T041-T042 tests run in parallel; T039-T040 verification in parallel
- Phase 5: T044-T047 tests run in parallel
- Phase 6: T050-T053 tests run in parallel
- Phase 7: T056-T060 tests run in parallel
- Phase 9: T069-T077, T083-T091 run in parallel

### What Blocks the First Working Screen (Phases 1-4)

Only 44 tasks (T001-T044). Everything in Phase 9 (25 tasks) is deferred.

---

## Implementation Strategy

### MVP Flow (Phases 1-4 Only)

1. **Setup** (T001-T009): Runnable FastAPI + DB
2. **Auth + Household** (T010-T028): Register/login → household auto-created + common utilities
3. **Storage Locations** (T029-T033): Fridge/Freezer/Pantry exist
4. **US1 Inventory** (T030-T044): Add item → see in list with Arabic text + Unicode/verification + contract tests

**STOP HERE** → Validate: register → login → add "فراخ متبلة" → see in list

### Incremental Delivery

1. Phases 1-4 → **MVP working** (add + list + Unicode verified + contract tests)
2. Phase 5 → Filter works
3. Phase 6 → Edit works
4. Phase 7 → Delete works + audit verification
5. Phase 8 → Reference dropdowns work
6. Phase 9 → Hardening, tests, advanced features

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at Phase 4 checkpoint to validate MVP
- Key constraints from data-model.md quoted in tasks:
  - `quantity > 0` (FR-005, CHECK constraint)
  - `name` NOT NULL, Unicode preserved (FR-002, FR-025, FR-028)
  - `notes` ≤ 500 chars (Assumption, CHECK constraint)
  - `category_key` ∈ `categories.key` (FR-006)
  - `unit_key` ∈ `units.key` (FR-007)
  - `storage_location_id` ∈ household's `storage_locations.id` (FR-008, household-owned)
  - `date_added` valid calendar date (Assumption)
  - `status` ∈ allowed values (Domain model)
  - `labels` contains `ar` and `en` (FR-006, FR-007)
  - `parent_id` references valid `id` in same household (FR-010)
  - `role` ∈ `('owner','admin','member')` (Domain model)

---

## Extension Hooks

**Optional Hook**: git
Command: `/speckit-git-commit`
Description: Auto-commit after task generation
Prompt: Commit task changes?
To execute: `/speckit-git-commit`