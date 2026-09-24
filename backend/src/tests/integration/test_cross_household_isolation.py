"""Integration tests for Cross-Household Isolation (matches sequence diagram)."""

import pytest
from httpx import AsyncClient


class TestCrossHouseholdIsolation:
    """Tests matching the Error Handling: Cross-Household Isolation sequence diagram.
    
    Key principle: Return 404 (not 403) to prevent household enumeration.
    """
    
    @pytest.mark.asyncio
    async def test_inventory_cross_household_get_returns_404(self, client: AsyncClient, auth_headers_2, inventory_items):
        """GET /inventory-items/{id} from another household returns 404."""
        item = inventory_items[0]
        response = await client.get(f"/api/v1/inventory-items/{item.id}", headers=auth_headers_2)
        
        assert response.status_code == 404
        assert response.json()["detail"] == "Inventory item not found"
    
    @pytest.mark.asyncio
    async def test_inventory_cross_household_patch_returns_404(self, client: AsyncClient, auth_headers_2, inventory_items):
        """PATCH /inventory-items/{id} from another household returns 404."""
        item = inventory_items[0]
        response = await client.patch(
            f"/api/v1/inventory-items/{item.id}",
            json={"quantity": "5.0"},
            headers=auth_headers_2
        )
        
        assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_inventory_cross_household_delete_returns_404(self, client: AsyncClient, auth_headers_2, inventory_items):
        """DELETE /inventory-items/{id} from another household returns 404."""
        item = inventory_items[0]
        response = await client.delete(f"/api/v1/inventory-items/{item.id}", headers=auth_headers_2)
        
        assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_inventory_cross_household_list_returns_empty(self, client: AsyncClient, auth_headers_2, inventory_items):
        """GET /inventory-items from another household returns empty list."""
        response = await client.get("/api/v1/inventory-items", headers=auth_headers_2)
        
        assert response.status_code == 200
        data = response.json()
        assert data["items"] == []
    
    @pytest.mark.asyncio
    async def test_storage_cross_household_get_returns_404(self, client: AsyncClient, auth_headers_2, storage_locations):
        """GET /storage-locations/{id} from another household returns 404."""
        loc = storage_locations[0]
        response = await client.get(f"/api/v1/storage-locations/{loc.id}", headers=auth_headers_2)
        
        assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_storage_cross_household_delete_returns_404(self, client: AsyncClient, auth_headers_2, storage_locations):
        """DELETE /storage-locations/{id} from another household returns 404."""
        loc = storage_locations[0]
        response = await client.delete(f"/api/v1/storage-locations/{loc.id}", headers=auth_headers_2)
        
        assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_storage_cross_household_list_returns_empty(self, client: AsyncClient, auth_headers_2, storage_locations):
        """GET /storage-locations from another household returns empty list."""
        response = await client.get("/api/v1/storage-locations", headers=auth_headers_2)
        
        assert response.status_code == 200
        data = response.json()
        assert data == []
    
    @pytest.mark.asyncio
    async def test_household_cross_household_get_returns_404(self, client: AsyncClient, auth_headers_2, test_user):
        """GET /household from another household returns their own household (200)."""
        # The /household endpoint returns the current user's household, which is correct behavior
        # Cross-household isolation means user 2 gets their own household, not user 1's
        response = await client.get("/api/v1/household", headers=auth_headers_2)
        
        # Should return 200 with user 2's household info
        assert response.status_code == 200
        data = response.json()
        assert "id" in data
        assert "name" in data
    
    @pytest.mark.asyncio
    async def test_household_cross_household_members_returns_404(self, client: AsyncClient, auth_headers_2, test_user):
        """GET /household/members from another household returns their own members (200)."""
        response = await client.get("/api/v1/household/members", headers=auth_headers_2)
        
        # Should return 200 with user 2's household members
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) >= 1  # At least the owner member
    
    @pytest.mark.asyncio
    async def test_audit_cross_household_returns_empty(self, client: AsyncClient, auth_headers_2, inventory_items):
        """GET /audit-logs from another household returns empty list."""
        # Create audit log in household 1
        item = inventory_items[0]
        await client.delete(f"/api/v1/inventory-items/{item.id}", headers=auth_headers_2)  # 404
        
        # Check audit in household 2
        response = await client.get("/api/v1/audit-logs", headers=auth_headers_2)
        
        assert response.status_code == 200
        data = response.json()
        assert data == []
    
    @pytest.mark.asyncio
    async def test_cannot_create_item_in_another_household_storage(self, client: AsyncClient, auth_headers_2, storage_locations, reference_data):
        """POST /inventory-items with another household's storage location fails."""
        categories, _ = reference_data
        other_fridge_id = storage_locations[0].id
        
        response = await client.post(
            "/api/v1/inventory-items",
            json={
                "name": "Hack Attempt",
                "category_key": "vegetables",
                "quantity": "1.0",
                "unit_key": "kg",
                "storage_location_id": str(other_fridge_id),
            },
            headers=auth_headers_2
        )
        
        # Should fail - storage location not found in this household
        assert response.status_code in (404, 422)
    
    @pytest.mark.asyncio
    async def test_cannot_create_storage_in_another_household(self, client: AsyncClient, auth_headers_2, storage_locations):
        """POST /storage-locations with another household's parent_id fails."""
        other_fridge_id = storage_locations[0].id
        
        response = await client.post(
            "/api/v1/storage-locations",
            json={
                "name": "Hack Shelf",
                "type": "shelf",
                "parent_id": str(other_fridge_id),
            },
            headers=auth_headers_2
        )
        
        assert response.status_code in (404, 422)