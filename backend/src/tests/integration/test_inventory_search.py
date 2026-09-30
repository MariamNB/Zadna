"""Search must cover the household inventory before pagination is applied."""

from datetime import datetime, timezone

import pytest


@pytest.mark.asyncio
@pytest.mark.parametrize("query,expected", [
    (" tomato ", {"Tomatoes"}),
    ("CHICKEN", {"Chicken Breast"}),
    ("Main Fridge", {"Tomatoes", "Milk"}),
    ("ألبان", {"Milk"}),
    ("vegetables", {"Tomatoes"}),
    ("missing item", set()),
    ("%", set()),
    ("_", set()),
])
async def test_inventory_search(client, auth_headers, inventory_items, query, expected):
    response = await client.get(
        "/api/v1/inventory-items", params={"q": query}, headers=auth_headers,
    )
    assert response.status_code == 200
    assert {item["name"] for item in response.json()["items"]} == expected


@pytest.mark.asyncio
async def test_search_pagination_and_category(client, auth_headers, inventory_items, db_session):
    # Identical timestamps exercise the UUID tie-breaker in cursor pagination.
    for item in inventory_items:
        item.created_at = datetime(2026, 1, 1, tzinfo=timezone.utc)
    await db_session.commit()
    seen = []
    cursor = None
    for _ in range(3):
        params = {"q": "Main Fridge", "limit": 1}
        if cursor:
            params["cursor"] = cursor
        response = await client.get(
            "/api/v1/inventory-items", params=params, headers=auth_headers,
        )
        assert response.status_code == 200
        page = response.json()
        seen.extend(item["name"] for item in page["items"])
        cursor = page["next_page_token"]
        if cursor is None:
            break
    assert sorted(seen) == ["Milk", "Tomatoes"]
    assert cursor is None

    response = await client.get(
        "/api/v1/inventory-items",
        params={"q": "Main Fridge", "category": "dairy"},
        headers=auth_headers,
    )
    assert [item["name"] for item in response.json()["items"]] == ["Milk"]


@pytest.mark.asyncio
async def test_search_keeps_households_isolated(client, auth_headers_2, inventory_items):
    response = await client.get(
        "/api/v1/inventory-items", params={"q": "Tomatoes"}, headers=auth_headers_2,
    )
    assert response.status_code == 200
    assert response.json()["items"] == []
