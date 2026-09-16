# Feature Specification: Household Food Inventory

**Feature Branch**: `001-household-food-inventory`

**Created**: 2026-09-07

**Status**: Draft

**Input**: User description: "Build the first feature of the Smart Fridge & Freezer Organizer: a basic household food inventory. The goal of this feature is to allow a household member to record the food they currently have at home and easily understand what is available. This is the first MVP feature of the product."

## Clarifications

### Session 2026-09-07

- Q: How should households be created and how do users get assigned to them in v1? → A: Auto-create one household per user on the caller's first authenticated request to any inventory endpoint; the user is the sole member. No user-facing household-creation endpoint in v1.
- Q: How should the food-name field be structured — single free-form or per-language? → A: Single free-form Unicode field. Users type in whichever script they prefer (Arabic, English, or mixed). The system does not store or require a translation; user-entered names are never dual-language.
- Q: How should deletion behave — hard delete with audit only, or soft delete with a user-visible recovery window? → A: Hard delete with server-side audit log. The row is removed on explicit delete; the deletion audit record (FR-020) is the sole recovery mechanism and requires operator action. No user-facing undo, no soft-delete flag, no background purge job in v1.
- Q: When a user adds an item whose name already exists in their household, what should happen? → A: Always accept as a new row. No duplicate detection, no merge, no prompt. Two items with the same name are two independent rows. Users can consolidate manually via edit or delete.
- Q: How should the inventory-list endpoint handle result size? → A: Return a pageable envelope from day one (`{ items: [...], next_page_token: null }`), but v1 always returns every item in a single page (`next_page_token` always `null`). The envelope is reserved so future paging can ship without a breaking API change; no client-visible pagination UI in v1.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Record and view household food (Priority: P1)

A household member opens the app and adds a food item they just brought home — for
example, a kilo of ground beef going into the freezer. They enter the name (in Arabic
or English), pick a category, enter a quantity and unit, choose a storage location,
and optionally add a note. The item appears in their household's inventory list, which
they can revisit at any time to see what they currently have at home.

**Why this priority**: This is the entire point of the MVP. Without add-and-view, the
feature has zero user value and no other story can exist. Every other story (filter,
edit, delete) is an incremental improvement over this base.

**Independent Test**: A single authenticated user adds one food item and then retrieves
the inventory list; the item appears with every field they entered, preserved
byte-exact including any Arabic text.

**Acceptance Scenarios**:

1. **Given** an authenticated household member with an empty inventory, **When** they add a food item with an Arabic name ("فراخ متبلة"), category "Meat & Poultry", quantity 1.5, unit "kilogram", storage location "Freezer", and note "متبلة للشوي", **Then** the item is saved and appears in the inventory list with all fields exactly as entered, including the Arabic characters.
2. **Given** an authenticated household member with an empty inventory, **When** they add an item with only the required fields (name, category, quantity, unit, storage location), **Then** the item is saved with `date_added` defaulted to today and `notes` empty.
3. **Given** a household with 5 food items, **When** a member of that household retrieves the inventory, **Then** all 5 items are returned with name, category, quantity, unit, storage location, and date added.
4. **Given** a household member of Household A, **When** they attempt to retrieve inventory using Household B's identifier, **Then** the system refuses the request and returns no data from Household B (not even a count).

---

### User Story 2 - Filter inventory by category or storage location (Priority: P2)

A user with a growing inventory wants to quickly see just the meats, or just what's
in the freezer. They apply one or both filters and the list narrows accordingly.

**Why this priority**: As inventory grows past ~10 items, the flat list becomes hard
to scan and filters restore fast browsing. But User Story 1 delivers value on its own —
a small inventory does not need filtering.

**Independent Test**: With User Story 1 in place, populate an inventory of mixed items
and verify that filtered queries return the correct subset.

**Acceptance Scenarios**:

1. **Given** a household with items in categories "Meat & Poultry", "Vegetables", and "Dairy", **When** the member filters by category "Meat & Poultry", **Then** only meat-and-poultry items are returned.
2. **Given** a household with items in storage locations "Fridge", "Freezer", and "Pantry", **When** the member filters by storage location "Freezer", **Then** only freezer items are returned.
3. **Given** items across multiple categories and locations, **When** the member filters by both category "Vegetables" AND storage location "Fridge", **Then** only items matching both filters are returned.
4. **Given** filters that match no items, **When** the query runs, **Then** an empty list is returned (not an error).

---

### User Story 3 - Edit an inventory item (Priority: P3)

A user notices they entered "1 kg" but should have said "2 kg", or they moved a
container from the fridge to the freezer. They open the item, change the affected
fields, and save.

**Why this priority**: Real inventories drift — quantities change, items move. Without
editing, users would have to delete and re-add, adding friction. But the app remains
useful without editing if the add path is frictionless.

**Independent Test**: With User Story 1 in place, create an item, update every field
in turn, and confirm the changes persist on the next read.

**Acceptance Scenarios**:

1. **Given** an existing food item in the caller's household, **When** the member updates its name, category, quantity, unit, storage location, date added, and notes, **Then** the item reflects all the updated values on the next read.
2. **Given** an existing food item, **When** the member updates only the quantity, **Then** all other fields remain unchanged.
3. **Given** a food item in Household A, **When** a member of Household B attempts to update it (using its identifier), **Then** the update is refused and the item is unchanged.
4. **Given** an edit that sets quantity to zero or a negative number, **When** the update is submitted, **Then** the update is refused with a structured validation error and the item is unchanged.

---

### User Story 4 - Delete an inventory item (Priority: P3)

A user finishes off the last of a container and wants to remove the item from
inventory. They initiate a delete, explicitly confirm it, and the item is gone.

**Why this priority**: Same reasoning as edit — needed for a truthful inventory, but
the app remains useful without it in the very short term.

**Independent Test**: With User Story 1 in place, create an item, delete it via the
explicit delete path, and verify it no longer appears in the inventory list.

**Acceptance Scenarios**:

1. **Given** an existing food item in the caller's household, **When** the member issues an explicit delete request for that item, **Then** the item is removed and no longer appears in the inventory list.
2. **Given** a request that does not explicitly signal delete (e.g., an update with a nulled name), **When** the system receives it, **Then** the item is not deleted.
3. **Given** a food item in Household A, **When** a member of Household B attempts to delete it (using its identifier), **Then** the delete is refused and the item remains.
4. **Given** an item that was deleted moments ago, **When** any member requests it, **Then** the system responds "not found" without revealing whether the identifier ever existed or belongs to another household.

---

### Edge Cases

- **Mixed-script name**: A name like "Chicken فراخ" (Arabic + English in one string) is stored and returned byte-exact.
- **Very long note**: Notes over the documented character limit are rejected at the API boundary with a structured error; nothing is silently truncated.
- **Zero or negative quantity**: Rejected as invalid input on both add and update — use delete instead.
- **Unknown category / unit / storage-location key**: An add or update referencing an identifier the system does not know is rejected with a structured validation error.
- **Future `date_added`**: A date in the future is accepted; validation only ensures a syntactically valid calendar date (see Assumptions).
- **Cross-household identifier probing**: Any request referencing an item identifier that belongs to another household receives the same response as "not found," so the response does not reveal whether the identifier exists in another household.
- **Filter with unknown category or storage-location key**: Returns an empty list, not an error.
- **Concurrent updates to the same item**: The last write wins; concurrency conflict resolution is not in scope for v1.

## Requirements *(mandatory)*

### Functional Requirements

**Adding food items**

- **FR-001**: System MUST allow an authenticated household member to add a food item with the fields: name, category, quantity, unit, storage location, date added (optional; defaults to today), and notes (optional).
- **FR-002**: System MUST accept food names containing Arabic characters, English characters, or a mix of both, and MUST preserve them byte-exact through storage and retrieval.
- **FR-003**: System MUST reject any add request that omits a required field (name, category, quantity, unit, storage location) with a structured validation error identifying the missing field.
- **FR-004**: System MUST default `date_added` to today (in the household's applicable calendar date) when the caller does not provide it.
- **FR-005**: System MUST accept `quantity` as a decimal number strictly greater than zero and MUST reject zero and negative values with a structured validation error.
- **FR-028**: System MUST represent the food-item name as a single free-form Unicode field. The system MUST NOT require, produce, or store a separate Arabic/English translation of a user-entered name; bilingual labeling applies only to reference data (categories, units, storage locations — FR-006, FR-007, FR-008).

**Categories, units, and storage locations (reference data)**

- **FR-006**: System MUST provide a fixed set of initial categories with stable machine-readable identifiers (`meat_poultry`, `fish_seafood`, `vegetables`, `fruits`, `dairy`, `cheese`, `prepared_food`, `homemade_frozen_food`, `sauces`, `dough_bakery`, `frozen_food`, `other`) and MUST return Arabic and English display labels for each.
- **FR-007**: System MUST provide a fixed set of initial units with stable machine-readable identifiers (`kilogram`, `gram`, `liter`, `milliliter`, `piece`, `package`, `bag`, `container`) and MUST return Arabic and English display labels for each.
- **FR-008**: System MUST provide a fixed set of initial storage locations with stable machine-readable identifiers (`fridge`, `freezer`, `pantry`) and MUST return Arabic and English display labels for each.
- **FR-009**: The category, unit, and storage-location reference data MUST be modeled so that new entries can be added later without changing the identifier scheme or breaking existing clients.
- **FR-010**: The storage-location model MUST allow a parent–child relationship in its schema so that later features can nest locations (e.g., Freezer → Drawer 2 → Section A) without a schema-breaking migration. v1 exposes only top-level locations.

**Retrieving and filtering inventory**

- **FR-011**: System MUST allow an authenticated household member to retrieve all inventory items belonging to their household.
- **FR-012**: Each item in the inventory list MUST include: item identifier, name, category (stable key + display labels), quantity, unit (stable key + display labels), storage location (stable key + display labels), and date added.
- **FR-013**: System MUST allow the inventory list to be filtered by category identifier, by storage-location identifier, or by both simultaneously (combined with AND semantics).
- **FR-014**: A filter referencing an unknown category or storage-location identifier MUST return an empty list, not a validation error.
- **FR-029**: The inventory-list response MUST be a pageable envelope of the shape `{ items: [...], next_page_token: null|string }`. In v1 the response MUST always contain every matching item in a single page and `next_page_token` MUST always be `null`. Clients MUST NOT rely on the absence of the envelope; the envelope MUST be present even when `items` is empty.

**Editing items**

- **FR-015**: System MUST allow an authenticated household member to update any of the following fields on an existing item in their own household's inventory: name, category, quantity, unit, storage location, date added, notes.
- **FR-016**: Field-level validation on an update MUST match the validation rules applied on add (FR-002, FR-003, FR-005, FR-006, FR-007, FR-008).
- **FR-017**: An update that fails validation MUST leave the item unchanged and MUST return a structured error identifying the offending field(s).

**Deleting items**

- **FR-018**: System MUST allow an authenticated household member to delete an existing item from their household's inventory only when the request explicitly signals a delete (e.g., a distinct DELETE operation), never as a side effect of any other action.
- **FR-019**: System MUST NOT silently delete inventory items via any background job, cleanup task, migration, or cascade in v1.
- **FR-020**: System MUST record every successful delete in an audit log capturing at least: acting user identifier, household identifier, item identifier, a snapshot of the item's fields at deletion time, and timestamp — so that manual recovery is possible.

**Authorization (cross-cutting)**

- **FR-021**: System MUST authenticate every inventory request; unauthenticated requests MUST be rejected before any household or item lookup occurs.
- **FR-022**: System MUST resolve the caller's household membership on every request and MUST reject any read, list, filter, add, update, or delete that references a household or item the caller does not belong to.
- **FR-023**: A request that references an inventory item identifier belonging to another household MUST receive the same response as "not found," so that the response does not reveal whether the identifier exists in another household.
- **FR-024**: System MUST log every rejected authorization attempt with enough context to detect enumeration attacks (acting user, target identifier, timestamp, request kind) and MUST NOT include user content (names, notes) in those logs.
- **FR-027**: On the caller's first authenticated request to any inventory endpoint, if the authenticated user is not already a member of any household, the system MUST auto-provision a new household with the caller as its sole member and use that household for the request. Auto-provisioning MUST be transparent to the caller (no user-facing bootstrap step) and MUST NOT be triggered by unauthenticated requests. No user-facing endpoint to create, join, leave, rename, or delete households exists in v1.

**Data preservation**

- **FR-025**: System MUST NOT normalize, trim, or otherwise mutate user-entered name and notes beyond rejecting invalid Unicode encodings. Any normalization used for search or sort MUST be stored alongside the original, not in place of it.
- **FR-026**: System MUST NOT delete or modify inventory data as a side effect of any operation other than an explicit user delete or update on that item.

### Key Entities

- **Household**: The unit of ownership for all inventory data. Every food item belongs to exactly one household. Each household has a stable identifier and one or more members.
- **Household Member**: An authenticated user's membership in a household. In v1, each user is a member of exactly one household, provisioned automatically on their first authenticated request (see FR-027); no API surface exists for users to join or leave.
- **Food Item**: A single entry in a household's inventory. Attributes: identifier, household (owner), name (free-form Unicode text), category (reference), quantity (decimal > 0), unit (reference), storage location (reference), date added (calendar date, defaults today), notes (optional Unicode text), created-at, updated-at. Belongs to exactly one household.
- **Category**: A reference entry with a stable identifier and localized display labels (Arabic + English). Fixed set in v1; extensible later.
- **Unit**: A reference entry with a stable identifier and localized display labels (Arabic + English). Fixed set in v1; extensible later.
- **Storage Location**: A reference entry with a stable identifier, localized display labels (Arabic + English), and an optional reference to a parent location to support future nesting. Fixed flat set in v1.
- **Deletion Audit Record**: A record produced on every successful delete, capturing acting user, household, item identifier, a snapshot of the item's fields at deletion, and timestamp. Used for manual recovery and security audit.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A household member can add a new food item — including a fully Arabic name — and see it appear in their inventory list within 15 seconds of tapping "add," averaged across 20 attempts by 5 users on a typical mobile network.
- **SC-002**: An inventory list of up to 200 items is fully visible to the user within 2 seconds of opening the list on a typical mobile network.
- **SC-003**: 100% of authorization attempts to access another household's inventory (by identifier probing, filter, or direct reference) are refused, verified by automated test coverage across every mutation and read path.
- **SC-004**: 100% of Arabic names and notes round-trip through add → list → edit → list without character loss, normalization, or corruption, verified by automated tests with a corpus of at least 20 Arabic-language food names and notes covering diacritics, tatweel, mixed Arabic-Indic digits, and mixed-script strings.
- **SC-005**: A user can complete the full add → filter → edit → delete flow on a single item without any silent data mutation, verified end-to-end.
- **SC-006**: Zero inventory items are deleted or altered without a corresponding explicit user action recorded in the audit log, verified over any 30-day operational window.
- **SC-007**: 95% of first-time users can add their first food item within 60 seconds of opening the add screen, measured by session analytics once the feature is released.

## Assumptions

- **Household bootstrapping (decided in clarification, see FR-027).** On the caller's first authenticated request, the system auto-provisions a household with that user as sole member. Users never call a household-creation endpoint in v1. Multi-user households, invitations, and household-management screens are out of scope for this feature and will arrive in a later feature.
- **Name-field shape (decided in clarification, see FR-028).** The food name is stored as a single free-form Unicode field. Users type in whichever language they prefer (Arabic, English, or mixed); the system does not require, produce, or store a translation into the other language.
- **Duplicate items are allowed (decided in clarification).** If a user adds "أرز" twice, both entries are stored as separate rows. The system performs no duplicate detection, no merge, and no prompt on add; consistent with "no silent mutation" (FR-025, FR-026). Users can consolidate manually via edit or delete.
- **Filters combine with AND.** When both a category filter and a storage-location filter are applied, only items matching both are returned.
- **`date_added` is user-editable.** Defaults to today on add; the user may change it (e.g., to backdate an item they had for a week). Future or past dates are accepted; validation only ensures a syntactically valid calendar date.
- **Notes have a documented length limit.** v1 sets an upper bound (target: 500 characters) to prevent abuse and enable predictable storage; the exact number is finalized during planning.
- **Reference data is server-managed.** In v1, users cannot add or rename categories, units, or storage locations. Identifiers and labels are seeded at deployment.
- **The API is versioned.** The first release of the inventory endpoints is `v1`; future breaking changes bump the version.
- **List-response envelope (decided in clarification, see FR-029).** Inventory reads always return `{ items: [...], next_page_token: null|string }`. v1 always returns everything in a single page (`next_page_token` = `null`); the envelope is reserved so later pagination can ship without breaking clients.
- **Localization payload shape.** Category, unit, and storage-location values are returned as an object with a stable `key` and a `label` map keyed by language code (`ar`, `en`), so clients render whichever language they need without renegotiating the contract when translations change.
- **Deletion model (decided in clarification, see FR-018 / FR-020).** An explicit delete removes the row from the live inventory. Recovery is not exposed as a user feature in v1, but the audit record (FR-020) makes manual server-side recovery possible. No soft-delete flag, no user-facing undo, no scheduled purge job.
- **Authentication mechanism is out of scope.** This feature assumes an existing authentication surface that identifies the caller and produces a household membership; the exact mechanism (session, token, etc.) is a planning decision, not a spec decision.
- **Timezone / calendar-date semantics.** `date_added` is a calendar date (not a timestamp); "today" is evaluated in a timezone that will be defined during planning (a reasonable default is the household's configured timezone, defaulting to UTC if none).
