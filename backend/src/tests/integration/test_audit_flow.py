"""Integration tests for Audit Log Flow (matches sequence diagram)."""

import pytest
from httpx import AsyncClient


class TestAuditFlow:
    """Tests matching the Audit Log Flow sequence diagram."""
    
    @pytest.mark.asyncio
    async def test_get_audit_logs(self, client: AsyncClient, auth_headers, inventory_items):
        """GET /audit-logs returns audit entries for household."""
        # First delete an item to create audit log
        item = inventory_items[0]
        response = await client.delete(f"/api/v1/inventory-items/{item.id}", headers=auth_headers)
        assert response.status_code == 204
        
        # Now fetch audit logs
        response = await client.get("/api/v1/audit-logs", headers=auth_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) >= 1
        
        # Verify structure
        log = data[0]
        assert "id" in log
        assert "action" in log
        assert "entity_type" in log
        assert "entity_id" in log
        assert "audit_metadata" in log  # Field is named audit_metadata in response
        assert "created_at" in log
        
        # Find the delete log
        delete_log = next((l for l in data if l["action"] == "delete"), None)
        assert delete_log is not None
        assert delete_log["entity_type"] == "inventory_item"
        assert delete_log["entity_id"] == str(item.id)
    
    @pytest.mark.asyncio
    async def test_get_audit_logs_filter_by_entity(self, client: AsyncClient, auth_headers, inventory_items):
        """GET /audit-logs?entity_type=...&entity_id=... filters by entity."""
        item = inventory_items[0]
        await client.delete(f"/api/v1/inventory-items/{item.id}", headers=auth_headers)
        
        response = await client.get(
            "/api/v1/audit-logs",
            params={"entity_type": "inventory_item", "entity_id": str(item.id)},
            headers=auth_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) >= 1
        for log in data:
            assert log["entity_type"] == "inventory_item"
            assert log["entity_id"] == str(item.id)
    
    @pytest.mark.asyncio
    async def test_get_audit_logs_limit(self, client: AsyncClient, auth_headers, inventory_items):
        """GET /audit-logs?limit=N limits results."""
        # Delete multiple items
        for item in inventory_items:
            await client.delete(f"/api/v1/inventory-items/{item.id}", headers=auth_headers)
        
        response = await client.get(
            "/api/v1/audit-logs",
            params={"limit": 2},
            headers=auth_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 2
    
    @pytest.mark.asyncio
    async def test_cross_household_isolation_audit(self, client: AsyncClient, auth_headers_2, inventory_items):
        """User A cannot see User B's audit logs."""
        item = inventory_items[0]
        await client.delete(f"/api/v1/inventory-items/{item.id}", headers=auth_headers_2)  # This will 404
        
        response = await client.get("/api/v1/audit-logs", headers=auth_headers_2)
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 0