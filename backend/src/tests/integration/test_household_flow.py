"""Integration tests for Household Flow (matches sequence diagram)."""

import pytest
from httpx import AsyncClient


class TestHouseholdFlow:
    """Tests matching the Household Info Flow sequence diagram."""
    
    @pytest.mark.asyncio
    async def test_get_household_info(self, client: AsyncClient, auth_headers, test_user):
        """GET /household returns current household info."""
        _, household, _ = test_user
        response = await client.get("/api/v1/household", headers=auth_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == str(household.id)
        assert data["name"] == household.name
        assert data["timezone"] == household.timezone
        assert "created_at" in data
    
    @pytest.mark.asyncio
    async def test_list_household_members(self, client: AsyncClient, auth_headers, test_user):
        """GET /household/members returns all members."""
        user, _, member = test_user
        response = await client.get("/api/v1/household/members", headers=auth_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) == 1
        
        member_data = data[0]
        assert member_data["user_id"] == str(user.id)
        assert member_data["household_id"] == str(member.household_id)
        assert member_data["role"] == member.role
        assert "joined_at" in member_data
    
    @pytest.mark.asyncio
    async def test_cross_household_isolation_household(self, client: AsyncClient, auth_headers_2, test_user):
        """User A cannot access User B's household info."""
        response = await client.get("/api/v1/household", headers=auth_headers_2)
        
        assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_cross_household_isolation_members(self, client: AsyncClient, auth_headers_2, test_user):
        """User A cannot see User B's household members."""
        response = await client.get("/api/v1/household/members", headers=auth_headers_2)
        
        assert response.status_code == 404