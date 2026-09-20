"""Integration tests for Reference Data Flow (matches sequence diagram)."""

import pytest
from httpx import AsyncClient


class TestReferenceDataFlow:
    """Tests matching the Reference Data Flow sequence diagram."""
    
    @pytest.mark.asyncio
    async def test_get_categories(self, client: AsyncClient, reference_data):
        """GET /reference/categories returns all categories with bilingual labels."""
        categories, _ = reference_data
        response = await client.get("/api/v1/reference/categories")
        
        assert response.status_code == 200
        data = response.json()
        assert "categories" in data
        assert len(data["categories"]) == len(categories)
        
        # Verify structure
        cat = data["categories"][0]
        assert "key" in cat
        assert "labels" in cat
        assert "en" in cat["labels"]
        assert "ar" in cat["labels"]
        assert "sort_order" in cat
        assert "is_active" in cat
        
        # Verify bilingual content
        veg_cat = next(c for c in data["categories"] if c["key"] == "vegetables")
        assert veg_cat["labels"]["en"] == "Vegetables"
        assert veg_cat["labels"]["ar"] == "خضروات"
    
    @pytest.mark.asyncio
    async def test_get_units(self, client: AsyncClient, reference_data):
        """GET /reference/units returns all units with bilingual labels."""
        _, units = reference_data
        response = await client.get("/api/v1/reference/units")
        
        assert response.status_code == 200
        data = response.json()
        assert "units" in data
        assert len(data["units"]) == len(units)
        
        # Verify structure
        unit = data["units"][0]
        assert "key" in unit
        assert "labels" in unit
        assert "en" in unit["labels"]
        assert "ar" in unit["labels"]
        assert "sort_order" in unit
        assert "is_active" in unit
        
        # Verify bilingual content
        kg_unit = next(u for u in data["units"] if u["key"] == "kg")
        assert kg_unit["labels"]["en"] == "Kilogram"
        assert kg_unit["labels"]["ar"] == "كيلوغرام"
    
    @pytest.mark.asyncio
    async def test_get_storage_locations_reference(self, client: AsyncClient, storage_locations):
        """GET /reference/storage-locations returns storage location types."""
        response = await client.get("/api/v1/reference/storage-locations")
        
        assert response.status_code == 200
        data = response.json()
        assert "storage_locations" in data
        # This endpoint might return global reference types or household-specific
        # Adjust based on actual implementation
    
    @pytest.mark.asyncio
    async def test_get_all_reference_data(self, client: AsyncClient, reference_data):
        """GET /reference returns all reference data at once."""
        response = await client.get("/api/v1/reference")
        
        assert response.status_code == 200
        data = response.json()
        assert "categories" in data
        assert "units" in data
        # storage_locations might be included or separate