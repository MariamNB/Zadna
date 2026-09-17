# Zadna — Smart Fridge & Freezer Organizer

A household food inventory system with a **FastAPI backend** (this repo) and a planned **Flutter mobile app**.

---

## App Concept

Help women and families easily track food in the fridge, freezer, and pantry — so they always know **what they have**, **what they can cook**, and **what to take out of the freezer ahead of time**.

### Core Questions the App Answers
1. **What do I have?** 🧊 — Digital inventory by category & location
2. **What can I cook?** 🍳 — Meal suggestions from available ingredients
3. **What should I take out?** ❄️ — Thaw-ahead recommendations

### Key Features (MVP + Planned)
| Status | Feature |
|--------|---------|
| ✅ Backend | Add/view/edit/delete inventory items (Arabic/English Unicode) |
| ✅ Backend | Categories, units, storage locations with bilingual labels |
| ✅ Backend | Filter by category & storage location |
| ✅ Backend | JWT auth + auto household provisioning |
| ✅ Backend | Cross-household isolation (404 on probe) |
| 🔜 Backend | Expiry/prepared/frozen dates, homemade flag, status |
| 🔜 Mobile | Voice input, photo recognition, AI recipe suggestions |
| 🔜 Mobile | Smart shopping list, family sharing |
| 🔜 Mobile | "What to cook" / "What to thaw" assistants |

---

## Tech Stack

**Backend** (this repo)
- Python 3.12, FastAPI 0.115, SQLAlchemy 2.0 (async), PostgreSQL 16
- JWT RS256 + Argon2, uv for dependencies
- Full Arabic/English Unicode support

**Mobile** (planned)
- Flutter (Dart)

---

## Project Structure

```
Zadna/
├── backend/           # FastAPI REST API
│   ├── src/app/
│   │   ├── auth/          # Authentication (JWT, RS256)
│   │   ├── households/    # Household auto-provisioning
│   │   ├── inventory/     # Food items CRUD + filtering
│   │   ├── storage/       # Storage locations (nesting-ready)
│   │   ├── reference/     # Categories, units, locations (bilingual)
│   │   ├── audit/         # Deletion audit log
│   │   └── common/        # Base models, pagination, exceptions
│   ├── alembic/           # DB migrations
│   └── pyproject.toml
├── specs/
│   └── 001-household-food-inventory/  # Spec, plan, tasks, data model
└── README.md
```

---

## API Endpoints (v1)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/v1/auth/register` | Register user |
| `POST` | `/api/v1/auth/login` | Login, returns JWT |
| `GET` | `/api/v1/inventory` | List items (filter by `category`, `storage_location`) |
| `POST` | `/api/v1/inventory` | Add item |
| `PATCH` | `/api/v1/inventory/{id}` | Update item |
| `DELETE` | `/api/v1/inventory/{id}` | Delete item (audit logged) |
| `GET` | `/api/v1/reference/categories` | All categories (ar/en labels) |
| `GET` | `/api/v1/reference/units` | All units (ar/en labels) |
| `GET` | `/api/v1/reference/storage-locations` | All locations (ar/en labels) |
| `GET` | `/api/v1/households/me` | Current user's household |

---

## Quick Start (Backend)

```bash
cd backend
cp .env.example .env          # edit DATABASE_URL, JWT keys
uv sync                       # install deps
uv run alembic upgrade head   # run migrations
uv run uvicorn app.main:app --reload
```

API docs at `http://localhost:8000/docs`

---

## Current Status

**Backend MVP complete**: Auth, households, inventory CRUD, filtering, reference data, audit logging — all tested and working.

**Next**: Flutter mobile app consuming this API.