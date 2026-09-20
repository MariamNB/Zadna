"""Pytest configuration and fixtures for integration tests."""

import uuid
from datetime import datetime, timezone
from decimal import Decimal
from typing import AsyncGenerator

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.pool import NullPool

from app.auth.models import User, RefreshToken
from app.auth.service import AuthService
from app.common.base_model import Base
from app.config import settings
from app.database import get_db
from app.households.models import Household, HouseholdMember
from app.inventory.models import InventoryItem
from app.main import create_app
from app.reference.models import Category, Unit
from app.storage.models import StorageLocation

# Test database URL (uses same DB but different schema or use test DB)
TEST_DATABASE_URL = settings.DATABASE_URL.replace("food_inventory", "food_inventory_test")


@pytest_asyncio.fixture(scope="session")
async def test_engine():
    """Create test database engine."""
    engine = create_async_engine(
        TEST_DATABASE_URL,
        poolclass=NullPool,
    )
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield engine
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()


@pytest_asyncio.fixture(scope="function")
async def db_session(test_engine) -> AsyncGenerator[AsyncSession, None]:
    """Create a new database session for each test."""
    async_session = async_sessionmaker(test_engine, class_=AsyncSession, expire_on_commit=False)
    async with async_session() as session:
        yield session
        await session.rollback()


@pytest_asyncio.fixture(scope="function")
async def client(db_session: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    """Create test client with overridden database dependency."""
    
    async def override_get_db():
        yield db_session
    
    app = create_app()
    app.dependency_overrides[get_db] = override_get_db
    
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac
    
    app.dependency_overrides.clear()


@pytest_asyncio.fixture
async def auth_service(db_session: AsyncSession) -> AuthService:
    """Create auth service instance."""
    return AuthService(db_session)


@pytest_asyncio.fixture
async def test_user(db_session: AsyncSession) -> tuple[User, Household, HouseholdMember]:
    """Create a test user with household and membership."""
    user = User(
        email="test@example.com",
        password_hash="hashed_password",
        is_active=True,
        email_verified=True,
    )
    db_session.add(user)
    await db_session.flush()
    
    household = Household(name="Test Household", timezone="UTC")
    db_session.add(household)
    await db_session.flush()
    
    member = HouseholdMember(
        household_id=household.id,
        user_id=user.id,
        role="admin",
    )
    db_session.add(member)
    await db_session.commit()
    await db_session.refresh(user)
    await db_session.refresh(household)
    await db_session.refresh(member)
    
    return user, household, member


@pytest_asyncio.fixture
async def test_user_2(db_session: AsyncSession) -> tuple[User, Household, HouseholdMember]:
    """Create a second test user with separate household."""
    user = User(
        email="test2@example.com",
        password_hash="hashed_password",
        is_active=True,
        email_verified=True,
    )
    db_session.add(user)
    await db_session.flush()
    
    household = Household(name="Test Household 2", timezone="UTC")
    db_session.add(household)
    await db_session.flush()
    
    member = HouseholdMember(
        household_id=household.id,
        user_id=user.id,
        role="admin",
    )
    db_session.add(member)
    await db_session.commit()
    await db_session.refresh(user)
    await db_session.refresh(household)
    await db_session.refresh(member)
    
    return user, household, member


@pytest_asyncio.fixture
async def auth_headers(client: AsyncClient, auth_service: AuthService, test_user) -> dict:
    """Get authentication headers for test user."""
    user, household, member = test_user
    # Use the auth service to create a token
    tokens = await auth_service.create_tokens(user.id, member.id, household.id)
    return {"Authorization": f"Bearer {tokens.access_token}"}


@pytest_asyncio.fixture
async def auth_headers_2(client: AsyncClient, auth_service: AuthService, test_user_2) -> dict:
    """Get authentication headers for second test user."""
    user, household, member = test_user_2
    tokens = await auth_service.create_tokens(user.id, member.id, household.id)
    return {"Authorization": f"Bearer {tokens.access_token}"}


@pytest_asyncio.fixture
async def reference_data(db_session: AsyncSession):
    """Create reference data (categories and units)."""
    categories = [
        Category(key="vegetables", labels={"en": "Vegetables", "ar": "خضروات"}, sort_order=1, is_active=True),
        Category(key="fruits", labels={"en": "Fruits", "ar": "فواكه"}, sort_order=2, is_active=True),
        Category(key="dairy", labels={"en": "Dairy", "ar": "ألبان"}, sort_order=3, is_active=True),
        Category(key="meat", labels={"en": "Meat", "ar": "لحوم"}, sort_order=4, is_active=True),
        Category(key="pantry", labels={"en": "Pantry Items", "ar": "مخزن"}, sort_order=5, is_active=True),
    ]
    units = [
        Unit(key="kg", labels={"en": "Kilogram", "ar": "كيلوغرام"}, sort_order=1, is_active=True),
        Unit(key="g", labels={"en": "Gram", "ar": "جرام"}, sort_order=2, is_active=True),
        Unit(key="piece", labels={"en": "Piece", "ar": "قطعة"}, sort_order=3, is_active=True),
        Unit(key="liter", labels={"en": "Liter", "ar": "لتر"}, sort_order=4, is_active=True),
        Unit(key="ml", labels={"en": "Milliliter", "ar": "ملليلتر"}, sort_order=5, is_active=True),
    ]
    for cat in categories:
        db_session.add(cat)
    for unit in units:
        db_session.add(unit)
    await db_session.commit()
    return categories, units


@pytest_asyncio.fixture
async def storage_locations(db_session: AsyncSession, test_user) -> list[StorageLocation]:
    """Create test storage locations."""
    _, household, member = test_user
    locations = [
        StorageLocation(
            household_id=household.id,
            name="Main Fridge",
            type="fridge",
            sort_order=1,
            created_by=member.id,
            updated_by=member.id,
        ),
        StorageLocation(
            household_id=household.id,
            name="Freezer",
            type="freezer",
            sort_order=2,
            created_by=member.id,
            updated_by=member.id,
        ),
        StorageLocation(
            household_id=household.id,
            name="Pantry",
            type="pantry",
            sort_order=3,
            created_by=member.id,
            updated_by=member.id,
        ),
    ]
    for loc in locations:
        db_session.add(loc)
    await db_session.commit()
    for loc in locations:
        await db_session.refresh(loc)
    return locations


@pytest_asyncio.fixture
async def inventory_items(db_session: AsyncSession, test_user, reference_data, storage_locations) -> list[InventoryItem]:
    """Create test inventory items."""
    _, household, member = test_user
    categories, units = reference_data
    
    items = [
        InventoryItem(
            household_id=household.id,
            name="Tomatoes",
            name_normalized="Tomatoes",
            category_key="vegetables",
            quantity=Decimal("2.5"),
            unit_key="kg",
            storage_location_id=storage_locations[0].id,  # Fridge
            prepared_at=None,
            frozen_at=None,
            opened_at=None,
            expires_at=None,
            is_homemade=False,
            status="stored",
            date_added=datetime.now(timezone.utc).date(),
            notes="Fresh tomatoes",
            created_by=member.id,
            updated_by=member.id,
        ),
        InventoryItem(
            household_id=household.id,
            name="Chicken Breast",
            name_normalized="Chicken Breast",
            category_key="meat",
            quantity=Decimal("1.0"),
            unit_key="kg",
            storage_location_id=storage_locations[1].id,  # Freezer
            frozen_at=datetime.now(timezone.utc).date(),
            is_homemade=False,
            status="stored",
            date_added=datetime.now(timezone.utc).date(),
            notes="Frozen chicken",
            created_by=member.id,
            updated_by=member.id,
        ),
        InventoryItem(
            household_id=household.id,
            name="Milk",
            name_normalized="Milk",
            category_key="dairy",
            quantity=Decimal("1.0"),
            unit_key="liter",
            storage_location_id=storage_locations[0].id,  # Fridge
            expires_at=datetime.now(timezone.utc).date(),
            is_homemade=False,
            status="stored",
            date_added=datetime.now(timezone.utc).date(),
            notes="Whole milk",
            created_by=member.id,
            updated_by=member.id,
        ),
    ]
    for item in items:
        db_session.add(item)
    await db_session.commit()
    for item in items:
        await db_session.refresh(item)
    return items