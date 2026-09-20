# Entity Relationship Diagram (ERD)

```mermaid
erDiagram
    %% ===========================
    %% AUTHENTICATION & USERS
    %% ===========================
    users ||--o{ household_members : "member_of"
    users ||--o{ refresh_tokens : "has"
    
    users {
        uuid id PK
        string email UK
        text password_hash
        bool is_active
        bool email_verified
        datetime created_at
        datetime updated_at
    }

    refresh_tokens {
        uuid id PK
        text token_hash
        uuid user_id FK
        datetime expires_at
        datetime revoked_at
        datetime created_at
        datetime updated_at
    }

    %% ===========================
    %% HOUSEHOLDS & MEMBERSHIP
    %% ===========================
    households ||--o{ household_members : "contains"
    households ||--o{ inventory_items : "owns"
    households ||--o{ storage_locations : "owns"
    households ||--o{ audit_logs : "logs"
    
    households {
        uuid id PK
        string name
        string timezone
        datetime created_at
        datetime updated_at
    }

    household_members {
        uuid id PK
        uuid household_id FK
        uuid user_id FK
        string role
        datetime joined_at
        datetime created_at
        datetime updated_at
    }

    %% ===========================
    %% REFERENCE DATA (Global)
    %% ===========================
    categories {
        string key PK
        string labels_ar
        string labels_en
        int sort_order
        bool is_active
    }

    units {
        string key PK
        string labels_ar
        string labels_en
        int sort_order
        bool is_active
    }

    %% ===========================
    %% STORAGE LOCATIONS (Hierarchical)
    %% ===========================
    storage_locations ||--o{ storage_locations : "parent_of"
    storage_locations ||--o{ inventory_items : "contains"
    households ||--o{ storage_locations : "owns"
    
    storage_locations {
        uuid id PK
        uuid household_id FK
        uuid parent_id FK
        string name
        string type
        int sort_order
        uuid created_by FK
        uuid updated_by FK
        datetime created_at
        datetime updated_at
    }

    %% ===========================
    %% INVENTORY ITEMS (Core)
    %% ===========================
    inventory_items }|--|| categories : "belongs_to"
    inventory_items }|--|| units : "measured_in"
    inventory_items }|--|| storage_locations : "stored_in"
    inventory_items }|--|| households : "owned_by"
    inventory_items }|--|| household_members : "created_by"
    inventory_items }|--|| household_members : "updated_by"
    inventory_items ||--o{ audit_logs : "audited"

    inventory_items {
        uuid id PK
        uuid household_id FK
        string name
        text name_normalized
        string category_key FK
        decimal quantity
        string unit_key FK
        uuid storage_location_id FK
        date prepared_at
        date frozen_at
        date opened_at
        date expires_at
        bool is_homemade
        string status
        date date_added
        text notes
        uuid created_by FK
        uuid updated_by FK
        datetime created_at
        datetime updated_at
    }

    %% ===========================
    %% AUDIT LOG
    %% ===========================
    audit_logs }|--|| households : "scoped_to"
    audit_logs }|--|| household_members : "performed_by"
    
    audit_logs {
        uuid id PK
        uuid household_id FK
        uuid actor_user_id FK
        string action
        string entity_type
        uuid entity_id
        json audit_metadata
        datetime created_at
    }
```

## Relationship Summary

| Parent | Child | Cardinality | Cascade | Notes |
|--------|-------|-------------|---------|-------|
| users | household_members | 1:N | delete-orphan | User can belong to multiple households |
| users | refresh_tokens | 1:N | delete-orphan | Tokens revoked on user delete |
| households | household_members | 1:N | delete-orphan | Members removed if household deleted |
| households | inventory_items | 1:N | delete-orphan | Items deleted with household |
| households | storage_locations | 1:N | delete-orphan | Locations deleted with household |
| households | audit_logs | 1:N | delete-orphan | Logs deleted with household |
| storage_locations | storage_locations | 1:N (self) | delete-orphan | Hierarchical nesting |
| storage_locations | inventory_items | 1:N | delete-orphan | Items deleted when location deleted |
| categories | inventory_items | 1:N | RESTRICT | Cannot delete category if items exist |
| units | inventory_items | 1:N | RESTRICT | Cannot delete unit if items exist |
| household_members | inventory_items (created_by) | 1:N | SET NULL | Preserve item, clear created_by |
| household_members | inventory_items (updated_by) | 1:N | SET NULL | Preserve item, clear updated_by |
| household_members | audit_logs | 1:N | - | Actor reference |

## Key Constraints

- **household_members**: Unique(household_id, user_id) - one membership per user per household
- **inventory_items**: quantity > 0, notes ≤ 500 chars, status ∈ {stored, thawing, consumed, discarded}
- **Cross-household isolation**: All queries filter by household_id from JWT
- **Reference data (categories, units)**: Global, not household-scoped
- **Bilingual labels**: categories.labels = {"ar": "...", "en": "..."} (JSON), same for units

## Indexes (Performance)

| Table | Index |
|-------|-------|
| users | email (unique) |
| refresh_tokens | user_id, expires_at |
| household_members | (household_id, user_id) unique |
| inventory_items | household_id, storage_location_id |
| inventory_items | household_id, category_key |
| inventory_items | household_id, category_key, storage_location_id |
| inventory_items | household_id, created_at |
| storage_locations | household_id, parent_id |
| audit_logs | household_id, entity_type, entity_id |
| audit_logs | created_at |