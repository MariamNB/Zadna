"""Integration tests for Storage Location Flow (matches sequence diagram)."""

import pytest
from httpx import AsyncClient


class TestStorageFlow:
    """Tests matching the Storage Location Management Flow sequence diagram."""
    
    @pytest.mark.asyncio
    async def test_list_storage_locations(self, client: AsyncClient, auth_headers, storage_locations):
        """GET /storage-locations returns all locations for household."""
        response = await client.get("/api/v1/storage-locations", headers=auth_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) == 3
        
        # Verify structure
        loc = data[0]
        assert "id" in loc
        assert "name" in loc
        assert "type" in loc
        assert "sort_order" in loc
        assert "parent_id" in loc
        assert "household_id" in loc
        assert "created_at" in loc
        assert "updated_at" in loc
    
    @pytest.mark.asyncio
    async def test_list_storage_locations_filter_by_parent(self, client: AsyncClient, auth_headers, storage_locations):
        """GET /storage-locations?parent_id=... filters by parent."""
        # First create a nested location
        fridge_id = storage_locations[0].id
        
        response = await client.post(
            "/api/v1/storage-locations",
            json={
                "name": "Top Shelf",
                "type": "shelf",
                "parent_id": str(fridge_id),
                "sort_order": 1,
            },
            headers=auth_headers
        )
        assert response.status_code == 201
        shelf = response.json()
        
        # Now filter by parent
        response = await client.get(
            "/api/v1/storage-locations",
            params={"parent_id": str(fridge_id)},
            headers=auth_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert data[0]["name"] == "Top Shelf"
        assert data[0]["parent_id"] == str(fridge_id)
    
    @pytest.mark.asyncio
    async def test_create_storage_location(self, client: AsyncClient, auth_headers):
        """POST /storage-locations creates new location."""
        response = await client.post(
            "/api/v1/storage-locations",
            json={
                "name": "Wine Fridge",
                "type": "fridge",
                "sort_order": 4,
            },
            headers=auth_headers
        )
        
        assert response.status_code == 201
        data = response.json()
        assert data["name"] == "Wine Fridge"
        assert data["type"] == "fridge"
        assert data["sort_order"] == 4
        assert data["parent_id"] is None
        assert "id" in data
    
    @pytest.mark.asyncio
    async def test_create_storage_location_with_parent(self, client: AsyncClient, auth_headers, storage_locations):
        """POST /storage-locations creates nested location."""
        fridge_id = storage_locations[0].id
        
        response = await client.post(
            "/api/v1/storage-locations",
            json={
                "name": "Vegetable Drawer",
                "type": "drawer",
                "parent_id": str(fridge_id),
                "sort_order": 1,
            },
            headers=auth_headers
        )
        
        assert response.status_code == 201
        data = response.json()
        assert data["name"] == "Vegetable Drawer"
        assert data["parent_id"] == str(fridge_id)
    
    @pytest.mark.asyncio
    async def test_get_storage_location(self, client: AsyncClient, auth_headers, storage_locations):
        """GET /storage-locations/{id} returns single location."""
        loc = storage_locations[0]
        response = await client.get(f"/api/v1/storage-locations/{loc.id}", headers=auth_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == str(loc.id)
        assert data["name"] == loc.name
    
    @pytest.mark.asyncio
    async def test_get_storage_location_not_found(self, client: AsyncClient, auth_headers):
        """GET /storage-locations/{id} for non-existent returns 404."""
        import uuid
        response = await client.get(f"/api/v1/storage-locations/{uuid.uuid4()}", headers=auth_headers)
        
        assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_update_storage_location(self, client: AsyncClient, auth_headers, storage_locations):
        """PATCH /storage-locations/{id} updates location."""
        loc = storage_locations[0]
        response = await client.patch(
            f"/api/v1/storage-locations/{loc.id}",
            json={"name": "Updated Fridge Name", "sort_order": 5},
            headers=auth_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "Updated Fridge Name"
        assert data["sort_order"] == 5
        assert data["id"] == str(loc.id)
    
    @pytest.mark.asyncio
    async def test_update_storage_location_not_found(self, client: AsyncClient, auth_headers):
        """PATCH /storage-locations/{id} for non-existent returns 404."""
        import uuid
        response = await client.patch(
            f"/api/v1/storage-locations/{uuid.uuid4()}",
            json={"name": "New Name"},
            headers=auth_headers
        )
        
        assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_delete_storage_location(self, client: AsyncClient, auth_headers, storage_locations):
        """DELETE /storage-locations/{id} deletes empty location."""
        # Create an empty location to delete
        response = await client.post(
            "/api/v1/storage-locations",
            json={"name": "To Delete", "type": "pantry"},
            headers=auth_headers
        )
        assert response.status_code == 201
        loc = response.json()
        
        response = await client.delete(f"/api/v1/storage-locations/{loc['id']}", headers=auth_headers)
        assert response.status_code == 204
        
        # Verify deleted
        response = await client.get(f"/api/v1/storage-locations/{loc['id']}", headers=auth_headers)
        assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_delete_storage_location_with_items_fails(self, client: AsyncClient, auth_headers, storage_locations, inventory_items):
        """DELETE /storage-locations/{id} fails if location contains items."""
        # Fridge has items
        fridge_id = storage_locations[0].id
        
        response = await client.delete(f"/api/v1/storage-locations/{fridge_id}", headers=auth_headers)
        
        # Should fail - either 400, 409, or 404 depending on implementation
        assert response.status_code in (400, 409, 404)
    
    @pytest.mark.asyncio
    async def test_delete_storage_location_with_children_fails(self, client: AsyncClient, auth_headers, storage_locations):
        """DELETE /storage-locations/{id} fails if location has children."""
        # Create a child location
        fridge_id = storage_locations[0].id
        response = await client.post(
            "/api/v1/storage-locations",
            json={"name": "Child Shelf", "type": "shelf", "parent_id": str(fridge_id)},
            headers=auth_headers
        )
        assert response.status_code == 201
        
        # Try to delete parent
        response = await client.delete(f"/api/v1/storage-locations/{fridge_id}", headers=auth_headers)
        
        # Should fail
        assert response.status_code in (400, 409, 404)
    
    @pytest.mark.asyncio
    async def test_cross_household_isolation_storage(self, client: AsyncClient, auth_headers, auth_headers_2, storage_locations):
        """User A cannot access User B's storage locations - returns 404."""
        loc = storage_locations[0]
        response = await client.get(f"/api/v1/storage-locations/{loc.id}", headers=auth_headers_2)
        
        assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_cross_household_isolation_storage_list(self, client: AsyncClient, auth_headers_2, storage_locations):
        """User A cannot see User B's storage locations in list."""
        response = await client.get("/api/v1/storage-locations", headers=auth_headers_2)
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 0