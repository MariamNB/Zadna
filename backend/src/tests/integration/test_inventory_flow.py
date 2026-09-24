"""Integration tests for Inventory CRUD Flow (matches sequence diagram)."""

import pytest
from httpx import AsyncClient


class TestInventoryFlow:
    """Tests matching the Inventory CRUD Flow sequence diagram."""
    
    @pytest.mark.asyncio
    async def test_list_inventory_items(self, client: AsyncClient, auth_headers, inventory_items):
        """GET /inventory-items returns paginated items."""
        response = await client.get("/api/v1/inventory-items", headers=auth_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert "items" in data
        assert "next_page_token" in data
        assert len(data["items"]) == 3
        
        # Verify item structure
        item = data["items"][0]
        assert "id" in item
        assert "name" in item
        assert "category_key" in item
        assert "quantity" in item
        assert "unit_key" in item
        assert "storage_location_id" in item
        assert "status" in item
    
    @pytest.mark.asyncio
    async def test_list_inventory_items_filter_by_category(self, client: AsyncClient, auth_headers, inventory_items):
        """GET /inventory-items?category=vegetables filters by category."""
        response = await client.get(
            "/api/v1/inventory-items",
            params={"category": "vegetables"},
            headers=auth_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert len(data["items"]) == 1
        assert data["items"][0]["category_key"] == "vegetables"
        assert data["items"][0]["name"] == "Tomatoes"
    
    @pytest.mark.asyncio
    async def test_list_inventory_items_filter_by_storage_location(self, client: AsyncClient, auth_headers, inventory_items, storage_locations):
        """GET /inventory-items?storage_location_id=... filters by location."""
        fridge_id = storage_locations[0].id
        response = await client.get(
            "/api/v1/inventory-items",
            params={"storage_location_id": str(fridge_id)},
            headers=auth_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        # Tomatoes and Milk are in fridge
        assert len(data["items"]) == 2
        for item in data["items"]:
            assert item["storage_location_id"] == str(fridge_id)
    
    @pytest.mark.asyncio
    async def test_list_inventory_items_pagination(self, client: AsyncClient, auth_headers, inventory_items):
        """GET /inventory-items?limit=2 returns paginated results."""
        response = await client.get(
            "/api/v1/inventory-items",
            params={"limit": 2},
            headers=auth_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert len(data["items"]) == 2
        assert data["next_page_token"] is not None
        
        # Fetch next page
        response2 = await client.get(
            "/api/v1/inventory-items",
            params={"limit": 2, "cursor": data["next_page_token"]},
            headers=auth_headers
        )
        assert response2.status_code == 200
        data2 = response2.json()
        assert len(data2["items"]) == 1
    
    @pytest.mark.asyncio
    async def test_create_inventory_item(self, client: AsyncClient, auth_headers, storage_locations, reference_data):
        """POST /inventory-items creates new item."""
        categories, units = reference_data
        fridge_id = storage_locations[0].id
        
        response = await client.post(
            "/api/v1/inventory-items",
            json={
                "name": "Carrots",
                "category_key": "vegetables",
                "quantity": "1.5",
                "unit_key": "kg",
                "storage_location_id": str(fridge_id),
                "is_homemade": False,
                "notes": "Organic carrots",
            },
            headers=auth_headers
        )
        
        assert response.status_code == 201
        data = response.json()
        assert data["name"] == "Carrots"
        assert data["category_key"] == "vegetables"
        # Decimal(10,3) returns "1.500" for 1.5
        assert data["quantity"] == "1.500"
        assert data["unit_key"] == "kg"
        assert data["storage_location_id"] == str(fridge_id)
        assert data["status"] == "stored"
        assert "id" in data
        assert "created_at" in data
    
    @pytest.mark.asyncio
    async def test_create_inventory_item_invalid_category(self, client: AsyncClient, auth_headers, storage_locations):
        """POST /inventory-items with invalid category returns 422."""
        fridge_id = storage_locations[0].id
        
        response = await client.post(
            "/api/v1/inventory-items",
            json={
                "name": "Invalid Item",
                "category_key": "nonexistent",
                "quantity": "1.0",
                "unit_key": "kg",
                "storage_location_id": str(fridge_id),
            },
            headers=auth_headers
        )
        
        assert response.status_code == 422
    
    @pytest.mark.asyncio
    async def test_create_inventory_item_invalid_storage_location(self, client: AsyncClient, auth_headers):
        """POST /inventory-items with invalid storage location returns 422/404."""
        import uuid
        response = await client.post(
            "/api/v1/inventory-items",
            json={
                "name": "Invalid Item",
                "category_key": "vegetables",
                "quantity": "1.0",
                "unit_key": "kg",
                "storage_location_id": str(uuid.uuid4()),
            },
            headers=auth_headers
        )
        
        assert response.status_code in (404, 422)
    
    @pytest.mark.asyncio
    async def test_get_inventory_item(self, client: AsyncClient, auth_headers, inventory_items):
        """GET /inventory-items/{id} returns single item."""
        item = inventory_items[0]
        response = await client.get(f"/api/v1/inventory-items/{item.id}", headers=auth_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == str(item.id)
        assert data["name"] == item.name
    
    @pytest.mark.asyncio
    async def test_get_inventory_item_not_found(self, client: AsyncClient, auth_headers):
        """GET /inventory-items/{id} for non-existent item returns 404."""
        import uuid
        response = await client.get(f"/api/v1/inventory-items/{uuid.uuid4()}", headers=auth_headers)
        
        assert response.status_code == 404
        assert response.json()["detail"] == "Inventory item not found"
    
    @pytest.mark.asyncio
    async def test_update_inventory_item(self, client: AsyncClient, auth_headers, inventory_items):
        """PATCH /inventory-items/{id} updates item."""
        item = inventory_items[0]
        response = await client.patch(
            f"/api/v1/inventory-items/{item.id}",
            json={"quantity": "5.0", "notes": "Updated notes"},
            headers=auth_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        # Decimal(10,3) returns "5.000" for 5.0
        assert data["quantity"] == "5.000"
        assert data["notes"] == "Updated notes"
        assert data["id"] == str(item.id)
    
    @pytest.mark.asyncio
    async def test_update_inventory_item_not_found(self, client: AsyncClient, auth_headers):
        """PATCH /inventory-items/{id} for non-existent item returns 404."""
        import uuid
        response = await client.patch(
            f"/api/v1/inventory-items/{uuid.uuid4()}",
            json={"quantity": "5.0"},
            headers=auth_headers
        )
        
        assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_delete_inventory_item(self, client: AsyncClient, auth_headers, inventory_items):
        """DELETE /inventory-items/{id} deletes item and logs audit."""
        item = inventory_items[0]
        response = await client.delete(f"/api/v1/inventory-items/{item.id}", headers=auth_headers)
        
        assert response.status_code == 204
        
        # Verify item is gone
        response = await client.get(f"/api/v1/inventory-items/{item.id}", headers=auth_headers)
        assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_delete_inventory_item_not_found(self, client: AsyncClient, auth_headers):
        """DELETE /inventory-items/{id} for non-existent item returns 404."""
        import uuid
        response = await client.delete(f"/api/v1/inventory-items/{uuid.uuid4()}", headers=auth_headers)
        
        assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_cross_household_isolation_returns_404(self, client: AsyncClient, auth_headers, auth_headers_2, inventory_items):
        """User A cannot access User B's items - returns 404 not 403."""
        # Get an item from user 1's household
        item = inventory_items[0]
        
        # Try to access it with user 2's token
        response = await client.get(f"/api/v1/inventory-items/{item.id}", headers=auth_headers_2)
        
        # Should return 404 (not 403) to prevent household enumeration
        assert response.status_code == 404
        assert response.json()["detail"] == "Inventory item not found"
    
    @pytest.mark.asyncio
    async def test_cross_household_isolation_delete_returns_404(self, client: AsyncClient, auth_headers_2, inventory_items):
        """User A cannot delete User B's items - returns 404."""
        item = inventory_items[0]
        response = await client.delete(f"/api/v1/inventory-items/{item.id}", headers=auth_headers_2)
        
        assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_cross_household_isolation_list_returns_empty(self, client: AsyncClient, auth_headers_2, inventory_items):
        """User A cannot see User B's items in list - returns empty."""
        response = await client.get("/api/v1/inventory-items", headers=auth_headers_2)
        
        assert response.status_code == 200
        data = response.json()
        assert len(data["items"]) == 0