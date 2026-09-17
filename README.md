# Zadna — Smart Fridge & Freezer Organizer

A household food inventory system with a **FastAPI backend** (this repo) and a planned **Flutter mobile app**.

---

## App Concept

Help women and families easily track food in the fridge, freezer, and pantry — so they always know **what they have**, **what they can cook**, and **what to take out of the freezer ahead of time**.

### Core Questions the App Answers
1. **What do I have?**  — Digital inventory by category & location
2. **What can I cook?**  — Meal suggestions from available ingredients
3. **What should I take out?**  — Thaw-ahead recommendations

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

## Quick Start (Backend)

```bash
cd backend
cp .env.example .env          # edit DATABASE_URL, JWT keys
uv sync                       # install deps
uv run alembic upgrade head   # run migrations
uv run uvicorn app.main:app --reload
```

---

## Current Status

**Backend MVP complete**: Auth, households, inventory CRUD, filtering, reference data, audit logging — all tested and working.

**Next**: Flutter mobile app consuming this API.
