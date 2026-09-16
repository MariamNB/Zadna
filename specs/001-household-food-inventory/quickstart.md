# Quickstart: Household Food Inventory

**Date**: 2026-09-13
**Feature**: 001-household-food-inventory

## Prerequisites

- Docker 24+ and Docker Compose v2+
- Python 3.12 (for local development without Docker)
- `uv` (recommended) or `pip` for dependency management
- `make` (optional, for convenience commands)

## Quick Start (Docker)

```bash
# 1. Clone and navigate
cd /home/mariam/projects/Zadna

# 2. Copy environment template
cp backend/.env.example backend/.env

# 3. Start PostgreSQL and API
docker compose -f backend/docker-compose.yml up -d

# 4. Run migrations
docker compose -f backend/docker-compose.yml exec api alembic upgrade head

# 5. Verify health
curl http://localhost:8000/health
# {"status": "ok"}
```

API available at: http://localhost:8000/api/v1
OpenAPI docs at: http://localhost:8000/docs

## Quick Start (Local Python with uv)

```bash
# 1. Navigate to backend
cd backend

# 2. Create virtual environment and install dependencies
uv sync --dev

# Or with pip:
# python3.12 -m venv .venv
# source .venv/bin/activate
# pip install -e ".[dev]"

# 3. Start PostgreSQL (Docker only for DB)
docker compose up -d postgres

# 4. Configure environment
cp .env.example .env
# Edit .env with your settings (DATABASE_URL, JWT keys, etc.)

# 5. Run migrations
alembic upgrade head

# 6. Start development server
uv run uvicorn app.main:app --reload --port 8000
```

## First API Call

### 1. Register a User (Auto-provisions Household)

```bash
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "testpass123"
  }'

# Response (201):
# {
#   "access_token": "eyJhbGciOiJSUzI1NiIs...",
#   "token_type": "bearer",
#   "expires_in": 900,
#   "refresh_token": "opaque-refresh-token"
# }
```

### 2. Add an Inventory Item

```bash
TOKEN="eyJhbGciOiJSUzI1NiIs..."

curl -X POST http://localhost:8000/api/v1/inventory-items \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "فراخ متبلة",
    "category_key": "meat_poultry",
    "quantity": 1.5,
    "unit_key": "kilogram",
    "storage_location_id": "550e8400-e29b-41d4-a716-446655440000",
    "notes": "متبلة للشوي",
    "is_homemade": true,
    "prepared_at": "2026-09-10",
    "frozen_at": "2026-09-10"
  }'

# Response (201):
# {
#   "id": "550e8400-e29b-41d4-a716-446655440000",
#   "name": "فراخ متبلة",
#   "category": {"key": "meat_poultry", "labels": {"ar": "اللحوم والدواجن", "en": "Meat & Poultry"}},
#   "unit": {"key": "kilogram", "labels": {"ar": "كيلوجرام", "en": "Kilogram"}},
#   "storage_location": {"id": "...", "name": "Freezer", "type": "freezer", ...},
#   "quantity": 1.5,
#   "date_added": "2026-09-13",
#   "notes": "متبلة للشوي",
#   "is_homemade": true,
#   "prepared_at": "2026-09-10",
#   "frozen_at": "2026-09-10",
#   "status": "stored",
#   "created_at": "2026-09-13T10:00:00Z",
#   "updated_at": "2026-09-13T10:00:00Z"
# }
```

### 3. List Inventory (with Pagination)

```bash
curl -X GET "http://localhost:8000/api/v1/inventory-items?limit=20" \
  -H "Authorization: Bearer $TOKEN"

# Response (200):
# {
#   "items": [...],
#   "next_page_token": "eyJjcmVhdGVkX2F0IjogIjIwMjYtMDktMTNUMTA6MDA6MDBaIiwgImlkIjogIjU1MGU4NDAwLWUyOWItNDE..."
# }
```

### 4. Filter by Category and Storage Location

```bash
# By category
curl -X GET "http://localhost:8000/api/v1/inventory-items?category=meat_poultry" \
  -H "Authorization: Bearer $TOKEN"

# By storage location
curl -X GET "http://localhost:8000/api/v1/inventory-items?storage_location_id=550e8400-e29b-41d4-a716-446655440000" \
  -H "Authorization: Bearer $TOKEN"

# Combined (AND)
curl -X GET "http://localhost:8000/api/v1/inventory-items?category=vegetables&storage_location_id=550e8400-e29b-41d4-a716-446655440000" \
  -H "Authorization: Bearer $TOKEN"
```

### 5. Get Reference Data (Categories & Units)

```bash
curl -X GET http://localhost:8000/api/v1/reference \
  -H "Authorization: Bearer $TOKEN"
```

### 6. Manage Storage Locations (Hierarchical)

```bash
# List top-level locations
curl -X GET "http://localhost:8000/api/v1/storage-locations?parent_id=null" \
  -H "Authorization: Bearer $TOKEN"

# Create nested location (e.g., Freezer → Drawer 2)
curl -X POST http://localhost:8000/api/v1/storage-locations \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Drawer 2",
    "type": "drawer",
    "parent_id": "FREEZER_UUID_HERE",
    "sort_order": 2
  }'

# List children of a location
curl -X GET "http://localhost:8000/api/v1/storage-locations?parent_id=FREEZER_UUID_HERE" \
  -H "Authorization: Bearer $TOKEN"
```

### 7. Update an Inventory Item

```bash
curl -X PATCH "http://localhost:8000/api/v1/inventory-items/550e8400-e29b-41d4-a716-446655440000" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"quantity": 2.0, "status": "thawing"}'
```

### 8. Delete an Inventory Item

```bash
curl -X DELETE "http://localhost:8000/api/v1/inventory-items/550e8400-e29b-41d4-a716-446655440000" \
  -H "Authorization: Bearer $TOKEN"
# 204 No Content
```

### 9. Get Household Info

```bash
curl -X GET http://localhost:8000/api/v1/household \
  -H "Authorization: Bearer $TOKEN"
```

### 10. Refresh Access Token

```bash
curl -X POST http://localhost:8000/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refresh_token": "opaque-refresh-token-from-login"}'
```

## Running Tests

```bash
# Unit tests (fast, no DB)
uv run pytest src/tests/unit -v

# Integration tests (requires PostgreSQL via testcontainers)
uv run pytest src/tests/integration -v

# Contract tests (validates against OpenAPI)
uv run pytest src/tests/contract -v

# Security tests (cross-household isolation)
uv run pytest src/tests/integration/test_security.py -v

# All tests
uv run pytest src/tests -v

# With coverage
uv run pytest src/tests --cov=app --cov-report=html
```

## Project Structure

```
backend/
├── src/
│   ├── app/                 # Application code
│   │   ├── main.py          # FastAPI app factory
│   │   ├── config.py        # Settings
│   │   ├── database.py      # SQLAlchemy setup
│   │   ├── common/          # Shared utilities, base classes
│   │   │   ├── base_model.py
│   │   │   ├── pagination.py
│   │   │   ├── unicode.py
│   │   │   └── exceptions.py
│   │   ├── auth/            # Authentication & authorization
│   │   ├── households/      # Household domain
│   │   ├── inventory/       # Food inventory domain
│   │   ├── storage/         # Storage locations domain
│   │   ├── reference/       # Global reference data
│   │   └── audit/           # Audit logging
│   └── tests/               # Test suites
│       ├── contract/
│       ├── integration/
│       └── unit/
├── alembic/                 # Database migrations
├── pyproject.toml           # Project config (uv)
├── uv.lock                  # Locked dependencies
├── Dockerfile
├── docker-compose.yml
├── docker-compose.test.yml  # For testcontainers CI
└── .env.example
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql+asyncpg://postgres:postgres@localhost:5432/food_inventory` |
| `JWT_PRIVATE_KEY_PATH` | Path to RS256 private key (PEM) | `./keys/private.pem` |
| `JWT_PUBLIC_KEY_PATH` | Path to RS256 public key (PEM) | `./keys/public.pem` |
| `JWT_ALGORITHM` | Signing algorithm | `RS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Access token lifetime | `15` |
| `REFRESH_TOKEN_EXPIRE_DAYS` | Refresh token lifetime | `30` |
| `APP_HOST` | Bind address | `0.0.0.0` |
| `APP_PORT` | Port | `8000` |
| `LOG_LEVEL` | Logging level | `INFO` |
| `MAX_PAGE_SIZE` | Max pagination limit | `100` |

## Generate JWT Keys (Development)

```bash
mkdir -p backend/keys
openssl genrsa -out backend/keys/private.pem 2048
openssl rsa -in backend/keys/private.pem -pubout -out backend/keys/public.pem
```

## Common Commands

```bash
# Create new migration
uv run alembic revision --autogenerate -m "description"

# Apply migrations
uv run alembic upgrade head

# Rollback last migration
uv run alembic downgrade -1

# View migration history
uv run alembic history

# Format code
uv run ruff format backend/src

# Lint
uv run ruff check backend/src

# Type check
uv run mypy backend/src/app
```

## Troubleshooting

### Database Connection Failed
- Ensure PostgreSQL container is healthy: `docker compose ps`
- Check `DATABASE_URL` in `.env`
- Verify port 5432 not in use

### JWT Key Errors
- Ensure keys exist at `JWT_PRIVATE_KEY_PATH` and `JWT_PUBLIC_KEY_PATH`
- Keys must be valid PEM format (RS256)

### Migration Errors
- `alembic upgrade head` fails: check migration SQL in `alembic/versions/`
- Reset DB: `docker compose down -v && docker compose up -d && alembic upgrade head`

### Arabic Text Issues
- Ensure terminal/editor uses UTF-8
- Database must use UTF-8 (default in PostgreSQL 16)
- FastAPI/Pydantic handle Unicode natively
- NFC normalization applied for search only; original text preserved

## Unicode Test Examples

Test these strings round-trip correctly:
```
دجاج
Marinated Chicken
دجاج Marinated Chicken
وجبة مجمدة
فراخ متبلة
كفتة بالصلصة
عجين مخبوز
صلصة طماطم
```

## Next Steps

1. Review `specs/001-household-food-inventory/spec.md` for full requirements
2. Check `plan.md` for technical decisions
3. Check `research.md` for design rationale
4. Check `data-model.md` for entity details, indexes, relationships
5. Run `/speckit-tasks` to generate implementation task list
6. Start implementing from `tasks.md`