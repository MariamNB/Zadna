# Data Model: Household Food Inventory

**Date**: 2026-09-13
**Feature**: 001-household-food-inventory

## Entity Overview

| Entity | Owner | Type | Purpose |
|--------|-------|------|---------|
| `User` | Global | Identity | Authentication subject |
| `Household` | Global | Domain | Ownership unit for all inventory data |
| `HouseholdMember` | Household | Membership | User ↔ Household with role |
| `InventoryItem` | Household | Inventory | Household's food instance/batch |
| `StorageLocation` | Household | Configuration | Hierarchical freezer/fridge/pantry structure |
| `Category` | Global | Reference | Food categories (localized) |
| `Unit` | Global | Reference | Measurement units (localized) |
| `AuditLog` | Household | Security | Immutable audit trail |

---

## 1. User

**Table**: `users`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `UUID` | PK, `gen_random_uuid()` | Stable identifier |
| `email` | `VARCHAR(255)` | NOT NULL, UNIQUE | Login identifier |
| `password_hash` | `TEXT` | NOT NULL | Argon2id hash |
| `is_active` | `BOOLEAN` | NOT NULL, DEFAULT `true` | Account status |
| `email_verified` | `BOOLEAN` | NOT NULL, DEFAULT `false` | Email verification status |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT `now()` | Registration timestamp |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT `now()` | Last update timestamp |

**Relationships**:
- One-to-many: `User → HouseholdMember` (via `household_members.user_id`)

**Indexes**:
- Primary key on `id`
- Unique index on `email`

**Notes**:
- Global identity; not household-scoped
- Password hash stored via Argon2id (pwdlib)
- Email verification stubbed for future

---

## 2. Household

**Table**: `households`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `UUID` | PK, `gen_random_uuid()` | Stable identifier |
| `name` | `VARCHAR(100)` | NOT NULL | Display name (e.g., "Ahmed's Household") |
| `timezone` | `VARCHAR(50)` | NOT NULL, DEFAULT `'UTC'` | IANA timezone for `date_added` default |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT `now()` | Creation timestamp |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT `now()` | Last update timestamp |

**Relationships**:
- One-to-many: `Household → HouseholdMember` (via `household_members.household_id`)
- One-to-many: `Household → InventoryItem` (via `inventory_items.household_id`)
- One-to-many: `Household → StorageLocation` (via `storage_locations.household_id`)
- One-to-many: `Household → AuditLog` (via `audit_logs.household_id`)

**Indexes**:
- Primary key on `id`

**Notes**:
- Auto-provisioned on user's first authenticated request (FR-027)
- `name` defaults to "{User}'s Household"
- `timezone` used for `date_added` default; v1 uses UTC
- No user-facing CRUD in v1

---

## 3. HouseholdMember

**Table**: `household_members`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `UUID` | PK, `gen_random_uuid()` | Stable identifier |
| `household_id` | `UUID` | FK → `households.id`, NOT NULL | Owning household |
| `user_id` | `UUID` | FK → `users.id`, NOT NULL | Member user |
| `role` | `VARCHAR(20)` | NOT NULL, DEFAULT `'member'`, CHECK `IN ('owner','admin','member')` | Permission level |
| `joined_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT `now()` | Membership timestamp |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT `now()` | Row creation |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT `now()` | Row update |

**Relationships**:
- Many-to-one: `HouseholdMember → Household` (via `household_id`)
- Many-to-one: `HouseholdMember → User` (via `user_id`)
- One-to-many: `HouseholdMember → InventoryItem` (via `inventory_items.created_by` / `updated_by`)
- One-to-many: `HouseholdMember → StorageLocation` (via `storage_locations.created_by` / `updated_by`)
- One-to-many: `HouseholdMember → AuditLog` (via `audit_logs.actor_user_id`)

**Indexes**:
- Primary key on `id`
- Unique index on `(household_id, user_id)` — one membership per user per household
- Index on `user_id` — fast lookup by auth subject
- Index on `household_id` — household member listing

**Roles**:
- `owner`: Full control, can delete household, manage members (future)
- `admin`: Manage inventory, storage, members (future)
- `member`: Read/write inventory, storage

**Notes**:
- In v1, each user gets exactly one household with role `owner`
- Model supports multiple users per household (future family sharing)
- No invitation API in v1; model ready for it

---

## 4. InventoryItem

**Table**: `inventory_items`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `UUID` | PK, `gen_random_uuid()` | Stable identifier |
| `household_id` | `UUID` | FK → `households.id`, NOT NULL | Owning household |
| `name` | `TEXT` | NOT NULL | Free-form Unicode (Arabic/English/mixed) |
| `name_normalized` | `TEXT` | NOT NULL | NFC-normalized for search |
| `category_key` | `VARCHAR(50)` | FK → `categories.key`, NOT NULL | Category reference |
| `quantity` | `NUMERIC(10,3)` | NOT NULL, CHECK `> 0` | Decimal quantity (FR-005) |
| `unit_key` | `VARCHAR(50)` | FK → `units.key`, NOT NULL | Unit reference |
| `storage_location_id` | `UUID` | FK → `storage_locations.id`, NOT NULL | Storage location (household-owned) |
| `prepared_at` | `DATE` | NULLABLE | When food was prepared/cooked |
| `frozen_at` | `DATE` | NULLABLE | When food was frozen |
| `opened_at` | `DATE` | NULLABLE | When package was opened |
| `expires_at` | `DATE` | NULLABLE | Expiry date (future feature) |
| `is_homemade` | `BOOLEAN` | NOT NULL, DEFAULT `false` | Homemade vs store-bought |
| `status` | `VARCHAR(20)` | NOT NULL, DEFAULT `'stored'`, CHECK `IN ('stored','thawing','consumed','discarded')` | Item lifecycle status |
| `date_added` | `DATE` | NOT NULL, DEFAULT `CURRENT_DATE` | Calendar date (FR-004, FR-024) |
| `notes` | `TEXT` | NULLABLE, CHECK `char_length(notes) <= 500` | Optional notes (max 500 chars) |
| `created_by` | `UUID` | FK → `household_members.id`, NOT NULL | Creator |
| `updated_by` | `UUID` | FK → `household_members.id`, NOT NULL | Last modifier |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT `now()` | Row creation timestamp |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT `now()` | Row update timestamp |

**Relationships**:
- Many-to-one: `InventoryItem → Household` (via `household_id`)
- Many-to-one: `InventoryItem → Category` (via `category_key`)
- Many-to-one: `InventoryItem → Unit` (via `unit_key`)
- Many-to-one: `InventoryItem → StorageLocation` (via `storage_location_id`)
- Many-to-one: `InventoryItem → HouseholdMember` (via `created_by`, `updated_by`)
- One-to-one: `InventoryItem → AuditLog` (on delete)

**Indexes**:
- Primary key on `id`
- Index on `household_id` — list/filter by household
- Composite index on `(household_id, storage_location_id)` — filter by location
- Composite index on `(household_id, category_key)` — filter by category
- Composite index on `(household_id, category_key, storage_location_id)` — combined filter
- Composite index on `(household_id, expires_at)` — future expiry queries
- Composite index on `(household_id, created_at)` — chronological ordering
- Index on `name_normalized` — search support

**Check Constraints**:
- `quantity > 0` (FR-005)
- `char_length(notes) <= 500` (Assumption: 500 char limit)
- `status IN ('stored','thawing','consumed','discarded')` — lifecycle

**Notes**:
- `name` stored as `TEXT` — byte-exact Unicode preservation (FR-002, FR-025, FR-028)
- `name_normalized` = NFC(`name`) for search/comparison only; original `name` never mutated
- No duplicate detection (Clarification: always accept as new row)
- `date_added` is `DATE` (not timestamp); user-editable (Assumption)
- `storage_location_id` references household-owned `StorageLocation`, not global reference
- `prepared_at`, `frozen_at`, `opened_at`, `expires_at` support future freezer/thawing/expiry features
- `is_homemade` distinguishes homemade frozen foods (marinated chicken, meatballs, stuffed vegetables, sauces, dough, ready-to-cook meals)
- `status` enables future workflow: stored → thawing → consumed/discarded
- `updated_at` auto-updated via trigger

---

## 5. StorageLocation

**Table**: `storage_locations`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `UUID` | PK, `gen_random_uuid()` | Stable identifier |
| `household_id` | `UUID` | FK → `households.id`, NOT NULL | Owning household |
| `parent_id` | `UUID` | FK → `storage_locations.id`, NULLABLE | Parent location (self-ref) |
| `name` | `VARCHAR(100)` | NOT NULL | Display name (e.g., "Drawer 2", "Section A") |
| `type` | `VARCHAR(30)` | NOT NULL, CHECK `IN ('fridge','freezer','pantry','garage_freezer','drawer','shelf','section','other')` | Location type |
| `sort_order` | `INTEGER` | NOT NULL, DEFAULT `0` | Display ordering within parent |
| `created_by` | `UUID` | FK → `household_members.id`, NOT NULL | Creator |
| `updated_by` | `UUID` | FK → `household_members.id`, NOT NULL | Last modifier |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT `now()` | Creation timestamp |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT `now()` | Last update timestamp |

**Relationships**:
- Many-to-one: `StorageLocation → Household` (via `household_id`)
- Self-referential: `StorageLocation → StorageLocation` (via `parent_id`) — enables arbitrary nesting
- One-to-many: `StorageLocation → InventoryItem` (via `inventory_items.storage_location_id`)
- Many-to-one: `StorageLocation → HouseholdMember` (via `created_by`, `updated_by`)

**Indexes**:
- Primary key on `id`
- Index on `household_id` — household's locations
- Index on `parent_id` — child lookup
- Composite index on `(household_id, parent_id)` — tree traversal
- Index on `sort_order` — ordering

**Seed Data (v1 — created per household on bootstrap)**:
```json
[
  {"name": "Fridge", "type": "fridge", "parent_id": null, "sort_order": 1},
  {"name": "Freezer", "type": "freezer", "parent_id": null, "sort_order": 2},
  {"name": "Pantry", "type": "pantry", "parent_id": null, "sort_order": 3}
]
```

**Notes**:
- Household-specific — every household configures its own structure
- Arbitrary nesting: Freezer → Drawer 2 → Section A
- `type` enables UI icons/grouping; not a rigid hierarchy
- v1 API exposes only top-level locations (FR-010); nesting ready for future
- Created automatically when household is provisioned

---

## 6. Category (Global Reference)

**Table**: `categories`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `key` | `VARCHAR(50)` | PK | Stable machine identifier (e.g., `meat_poultry`) |
| `labels` | `JSONB` | NOT NULL | `{"ar": "اللحوم والدواجن", "en": "Meat & Poultry"}` |
| `sort_order` | `INTEGER` | NOT NULL, DEFAULT `0` | Display ordering |
| `is_active` | `BOOLEAN` | NOT NULL, DEFAULT `true` | Soft-disable without deleting |

**Relationships**:
- One-to-many: `Category → InventoryItem` (via `inventory_items.category_key`)

**Indexes**:
- Primary key on `key`
- Index on `sort_order`

**Seed Data (v1 — global)**:
```json
[
  {"key": "meat_poultry", "labels": {"ar": "اللحوم والدواجن", "en": "Meat & Poultry"}, "sort_order": 1, "is_active": true},
  {"key": "fish_seafood", "labels": {"ar": "الأسماك والمأكولات البحرية", "en": "Fish & Seafood"}, "sort_order": 2, "is_active": true},
  {"key": "vegetables", "labels": {"ar": "الخضروات", "en": "Vegetables"}, "sort_order": 3, "is_active": true},
  {"key": "fruits", "labels": {"ar": "الفواكه", "en": "Fruits"}, "sort_order": 4, "is_active": true},
  {"key": "dairy", "labels": {"ar": "منتجات الألبان", "en": "Dairy"}, "sort_order": 5, "is_active": true},
  {"key": "cheese", "labels": {"ar": "الجبن", "en": "Cheese"}, "sort_order": 6, "is_active": true},
  {"key": "prepared_food", "labels": {"ar": "الأطعمة الجاهزة", "en": "Prepared Food"}, "sort_order": 7, "is_active": true},
  {"key": "homemade_frozen_food", "labels": {"ar": "أطعمة مجمدة منزلية", "en": "Homemade Frozen Food"}, "sort_order": 8, "is_active": true},
  {"key": "sauces", "labels": {"ar": "الصلصات", "en": "Sauces"}, "sort_order": 9, "is_active": true},
  {"key": "dough_bakery", "labels": {"ar": "العجين والمخبوزات", "en": "Dough & Bakery"}, "sort_order": 10, "is_active": true},
  {"key": "frozen_food", "labels": {"ar": "الأطعمة المجمدة", "en": "Frozen Food"}, "sort_order": 11, "is_active": true},
  {"key": "other", "labels": {"ar": "أخرى", "en": "Other"}, "sort_order": 99, "is_active": true}
]
```

**Notes**:
- Global reference data — same for all households
- `labels` JSONB: extensible to new languages without schema change (FR-009)
- `is_active`: hide deprecated categories without breaking existing items
- Fixed set in v1; extensible via migration

---

## 7. Unit (Global Reference)

**Table**: `units`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `key` | `VARCHAR(50)` | PK | Stable machine identifier (e.g., `kilogram`) |
| `labels` | `JSONB` | NOT NULL | `{"ar": "كيلوجرام", "en": "Kilogram"}` |
| `sort_order` | `INTEGER` | NOT NULL, DEFAULT `0` | Display ordering |
| `is_active` | `BOOLEAN` | NOT NULL, DEFAULT `true` | Soft-disable |

**Relationships**:
- One-to-many: `Unit → InventoryItem` (via `inventory_items.unit_key`)

**Indexes**:
- Primary key on `key`
- Index on `sort_order`

**Seed Data (v1 — global)**:
```json
[
  {"key": "kilogram", "labels": {"ar": "كيلوجرام", "en": "Kilogram"}, "sort_order": 1, "is_active": true},
  {"key": "gram", "labels": {"ar": "جرام", "en": "Gram"}, "sort_order": 2, "is_active": true},
  {"key": "liter", "labels": {"ar": "لتر", "en": "Liter"}, "sort_order": 3, "is_active": true},
  {"key": "milliliter", "labels": {"ar": "ملليلتر", "en": "Milliliter"}, "sort_order": 4, "is_active": true},
  {"key": "piece", "labels": {"ar": "قطعة", "en": "Piece"}, "sort_order": 5, "is_active": true},
  {"key": "package", "labels": {"ar": "عبوة", "en": "Package"}, "sort_order": 6, "is_active": true},
  {"key": "bag", "labels": {"ar": "كيس", "en": "Bag"}, "sort_order": 7, "is_active": true},
  {"key": "container", "labels": {"ar": "حاوية", "en": "Container"}, "sort_order": 8, "is_active": true}
]
```

---

## 8. AuditLog

**Table**: `audit_logs`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `UUID` | PK, `gen_random_uuid()` | Stable identifier |
| `household_id` | `UUID` | FK → `households.id`, NOT NULL | Owning household |
| `actor_user_id` | `UUID` | FK → `household_members.id`, NOT NULL | User who performed action |
| `action` | `VARCHAR(30)` | NOT NULL, CHECK `IN ('create','update','delete')` | Action type |
| `entity_type` | `VARCHAR(50)` | NOT NULL | Entity type (e.g., `inventory_item`) |
| `entity_id` | `UUID` | NOT NULL | Entity identifier |
| `metadata` | `JSONB` | NOT NULL | Action-specific metadata |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT `now()` | Action timestamp |

**Relationships**:
- Many-to-one: `AuditLog → Household` (via `household_id`)
- Many-to-one: `AuditLog → HouseholdMember` (via `actor_user_id`)

**Indexes**:
- Primary key on `id`
- Index on `household_id` — household audit trail
- Index on `actor_user_id` — user audit trail
- Composite index on `(entity_type, entity_id)` — entity history
- Index on `created_at` — chronological ordering

**Metadata Examples**:

For `inventory_item` delete:
```json
{
  "name": "فراخ متبلة",
  "category_key": "meat_poultry",
  "quantity": "1.5",
  "unit_key": "kilogram",
  "storage_location_id": "uuid-of-freezer",
  "date_added": "2026-09-13",
  "notes": "متبلة للشوي",
  "created_at": "2026-09-13T10:00:00Z",
  "updated_at": "2026-09-13T10:00:00Z"
}
```

For `inventory_item` update:
```json
{
  "before": {"quantity": "1.5", "storage_location_id": "uuid-of-fridge"},
  "after": {"quantity": "2.0", "storage_location_id": "uuid-of-freezer"}
}
```

**Notes**:
- Written in same transaction as the audited operation (service layer)
- Guaranteed capture — no async gap
- `entity_id` not a FK (target row may be deleted); `metadata` is the recovery source
- No user-facing access in v1; admin/internal only
- Covers all mutating operations: create, update, delete

---

## Entity Relationship Diagram

```
User (1) ──────< (N) HouseholdMember >────── (1) Household
                                                    │
                          ┌───────────────────────┼───────────────────────┐
                          ▼                       ▼                       ▼
                   InventoryItem           StorageLocation           AuditLog
                          │                       │
                          │                       │ (self-ref)
                          ▼                       ▼
                     Category (global)         [children]
                          │
                          ▼
                       Unit (global)
```

---

## Data Ownership Classification

| Entity | Ownership | Scope | Notes |
|--------|-----------|-------|-------|
| `User` | Global | System-wide | Authentication identity |
| `Household` | Global | System-wide | Domain root |
| `HouseholdMember` | Household | Household-scoped | Membership |
| `InventoryItem` | Household | Household-scoped | Core inventory |
| `StorageLocation` | Household | Household-scoped | User-configured hierarchy |
| `Category` | Global | System-wide | Reference data |
| `Unit` | Global | System-wide | Reference data |
| `AuditLog` | Household | Household-scoped | Security audit |

---

## Validation Rules Summary

| Entity | Rule | Source |
|--------|------|--------|
| `InventoryItem` | `quantity > 0` | FR-005 |
| `InventoryItem` | `name` NOT NULL, Unicode preserved | FR-002, FR-025, FR-028 |
| `InventoryItem` | `notes` ≤ 500 chars | Assumption |
| `InventoryItem` | `category_key` ∈ `categories.key` | FR-006 |
| `InventoryItem` | `unit_key` ∈ `units.key` | FR-007 |
| `InventoryItem` | `storage_location_id` ∈ household's `storage_locations.id` | FR-008, household-owned |
| `InventoryItem` | `date_added` valid calendar date | Assumption |
| `InventoryItem` | `status` ∈ allowed values | Domain model |
| `Category/Unit` | `labels` contains `ar` and `en` | FR-006, FR-007 |
| `StorageLocation` | `parent_id` references valid `id` in same household | FR-010 |
| `HouseholdMember` | `role` ∈ `('owner','admin','member')` | Domain model |

---

## Index Strategy

| Table | Index | Query Pattern |
|-------|-------|---------------|
| `inventory_items` | `(household_id, created_at DESC)` | List inventory (pagination cursor) |
| `inventory_items` | `(household_id, storage_location_id)` | Filter by location |
| `inventory_items` | `(household_id, category_key)` | Filter by category |
| `inventory_items` | `(household_id, category_key, storage_location_id)` | Combined filter |
| `inventory_items` | `(household_id, expires_at)` | Future expiry queries |
| `inventory_items` | `name_normalized` | Search by name |
| `storage_locations` | `(household_id, parent_id)` | Tree traversal |
| `household_members` | `user_id` | Auth → household resolution |
| `audit_logs` | `(household_id, created_at DESC)` | Audit trail |

**Principle**: Every inventory query is household-scoped → all indexes lead with `household_id`.

---

## Migration Strategy

1. **Initial migration**: Create all tables, indexes, constraints, triggers (`updated_at` auto-update)
2. **Seed migration**: Upsert global reference data (categories, units)
3. **Bootstrap function**: `create_household_for_user(user_id)` — creates household + membership (owner) + default storage locations in single transaction
4. **Future migrations**: Add columns (e.g., `household.timezone`), new reference data, schema evolution

All migrations versioned via Alembic; idempotent seed using `ON CONFLICT (key) DO UPDATE`.