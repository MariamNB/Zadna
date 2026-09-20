# API Sequence Diagrams

## Authentication Flow

```mermaid
sequenceDiagram
    actor User
    participant Client
    participant AuthAPI as /api/v1/auth
    participant DB as PostgreSQL

    User->>Client: Enters email/password
    Client->>AuthAPI: POST /register {email, password}
    AuthAPI->>DB: Check if email exists
    DB-->>AuthAPI: User not found
    AuthAPI->>DB: Hash password (Argon2)
    AuthAPI->>DB: Create user + household
    DB-->>AuthAPI: User created
    AuthAPI-->>Client: 201 {user_id, household_id}

    Client->>AuthAPI: POST /login {email, password}
    AuthAPI->>DB: Find user by email
    DB-->>AuthAPI: User record
    AuthAPI->>AuthAPI: Verify password (Argon2)
    AuthAPI->>AuthAPI: Generate JWT (RS256)
    AuthAPI-->>Client: 200 {access_token, token_type}
```

## Inventory CRUD Flow

```mermaid
sequenceDiagram
    actor User
    participant Client
    participant InventoryAPI as /api/v1/inventory
    participant DB as PostgreSQL
    participant Auth as JWT Middleware

    Note over Client,Auth: All requests include Authorization: Bearer <token>

    Client->>InventoryAPI: GET /inventory?category=vegetables&storage_location=fridge
    InventoryAPI->>Auth: Validate JWT, extract household_id
    Auth-->>InventoryAPI: household_id
    InventoryAPI->>DB: SELECT * FROM items WHERE household_id = ? AND category = ? AND storage_location = ?
    DB-->>InventoryAPI: Items list
    InventoryAPI-->>Client: 200 {items: [...]}

    Client->>InventoryAPI: POST /inventory {name, category_id, unit_id, storage_location_id, quantity, ...}
    InventoryAPI->>Auth: Validate JWT, extract household_id
    Auth-->>InventoryAPI: household_id
    InventoryAPI->>DB: INSERT INTO items (household_id, ...) VALUES (...)
    DB-->>InventoryAPI: Created item
    InventoryAPI-->>Client: 201 {item: {...}}

    Client->>InventoryAPI: PATCH /inventory/{id} {quantity: 5}
    InventoryAPI->>Auth: Validate JWT, extract household_id
    Auth-->>InventoryAPI: household_id
    InventoryAPI->>DB: SELECT * FROM items WHERE id = ? AND household_id = ?
    alt Item found
        DB-->>InventoryAPI: Item
        InventoryAPI->>DB: UPDATE items SET quantity = 5 WHERE id = ?
        DB-->>InventoryAPI: Updated item
        InventoryAPI-->>Client: 200 {item: {...}}
    else Item not found (or wrong household)
        DB-->>InventoryAPI: No rows
        InventoryAPI-->>Client: 404 Not Found
    end

    Client->>InventoryAPI: DELETE /inventory/{id}
    InventoryAPI->>Auth: Validate JWT, extract household_id
    Auth-->>InventoryAPI: household_id
    InventoryAPI->>DB: SELECT * FROM items WHERE id = ? AND household_id = ?
    alt Item found
        DB-->>InventoryAPI: Item
        InventoryAPI->>DB: INSERT INTO audit_log (item_id, action, old_data) VALUES (?, 'delete', ?)
        InventoryAPI->>DB: DELETE FROM items WHERE id = ?
        DB-->>InventoryAPI: Deleted
        InventoryAPI-->>Client: 204 No Content
    else Item not found (or wrong household)
        DB-->>InventoryAPI: No rows
        InventoryAPI-->>Client: 404 Not Found
    end
```

## Reference Data Flow

```mermaid
sequenceDiagram
    actor User
    participant Client
    participant RefAPI as /api/v1/reference
    participant DB as PostgreSQL

    Client->>RefAPI: GET /categories
    RefAPI->>DB: SELECT * FROM categories ORDER BY name_en
    DB-->>RefAPI: Categories list
    RefAPI-->>Client: 200 {categories: [{id, name_en, name_ar}, ...]}

    Client->>RefAPI: GET /units
    RefAPI->>DB: SELECT * FROM units ORDER BY name_en
    DB-->>RefAPI: Units list
    RefAPI-->>Client: 200 {units: [{id, name_en, name_ar, abbreviation}, ...]}

    Client->>RefAPI: GET /storage-locations
    RefAPI->>DB: SELECT * FROM storage_locations ORDER BY name_en
    DB-->>RefAPI: Locations list
    RefAPI-->>Client: 200 {locations: [{id, name_en, name_ar}, ...]}
```

## Storage Location Management Flow

```mermaid
sequenceDiagram
    actor User
    participant Client
    participant StorageAPI as /api/v1/storage
    participant DB as PostgreSQL
    participant Auth as JWT Middleware

    Client->>StorageAPI: GET /storage-locations
    StorageAPI->>Auth: Validate JWT, extract household_id
    Auth-->>StorageAPI: household_id
    StorageAPI->>DB: SELECT * FROM storage_locations WHERE household_id = ?
    DB-->>StorageAPI: Locations list
    StorageAPI-->>Client: 200 {locations: [...]}

    Client->>StorageAPI: POST /storage-locations {name_en, name_ar, parent_id}
    StorageAPI->>Auth: Validate JWT, extract household_id
    Auth-->>StorageAPI: household_id
    StorageAPI->>DB: INSERT INTO storage_locations (household_id, name_en, name_ar, parent_id) VALUES (...)
    DB-->>StorageAPI: Created location
    StorageAPI-->>Client: 201 {location: {...}}

    Client->>StorageAPI: PATCH /storage-locations/{id} {name_en: "New Freezer"}
    StorageAPI->>Auth: Validate JWT, extract household_id
    Auth-->>StorageAPI: household_id
    StorageAPI->>DB: SELECT * FROM storage_locations WHERE id = ? AND household_id = ?
    alt Found
        DB-->>StorageAPI: Location
        StorageAPI->>DB: UPDATE storage_locations SET name_en = ? WHERE id = ?
        DB-->>StorageAPI: Updated
        StorageAPI-->>Client: 200 {location: {...}}
    else Not found
        DB-->>StorageAPI: No rows
        StorageAPI-->>Client: 404 Not Found
    end
```

## Household Info Flow

```mermaid
sequenceDiagram
    actor User
    participant Client
    participant HouseholdAPI as /api/v1/households
    participant DB as PostgreSQL
    participant Auth as JWT Middleware

    Client->>HouseholdAPI: GET /households/me
    HouseholdAPI->>Auth: Validate JWT, extract household_id
    Auth-->>HouseholdAPI: household_id
    HouseholdAPI->>DB: SELECT * FROM households WHERE id = ?
    DB-->>HouseholdAPI: Household record
    HouseholdAPI-->>Client: 200 {household: {id, name, created_at}}
```

## Audit Log Flow

```mermaid
sequenceDiagram
    actor User
    participant Client
    participant AuditAPI as /api/v1/audit
    participant DB as PostgreSQL
    participant Auth as JWT Middleware

    Client->>AuditAPI: GET /audit?item_id=123
    AuditAPI->>Auth: Validate JWT, extract household_id
    Auth-->>AuditAPI: household_id
    AuditAPI->>DB: SELECT a.* FROM audit_log a JOIN items i ON a.item_id = i.id WHERE i.household_id = ? AND a.item_id = ?
    DB-->>AuditAPI: Audit entries
    AuditAPI-->>Client: 200 {audit_log: [{id, item_id, action, old_data, new_data, created_at}, ...]}
```

## Error Handling: Cross-Household Isolation

```mermaid
sequenceDiagram
    actor UserA
    participant ClientA
    participant InventoryAPI as /api/v1/inventory
    participant DB as PostgreSQL
    participant Auth as JWT Middleware

    Note over UserA,Auth: User A tries to access User B's item

    ClientA->>InventoryAPI: GET /inventory/999 (User B's item)
    InventoryAPI->>Auth: Validate JWT, extract household_id (User A's household)
    Auth-->>InventoryAPI: household_id = 1
    InventoryAPI->>DB: SELECT * FROM items WHERE id = 999 AND household_id = 1
    DB-->>InventoryAPI: No rows (item 999 belongs to household 2)
    InventoryAPI-->>ClientA: 404 Not Found
    Note over ClientA: Returns 404, NOT 403 - prevents household enumeration
```