"""Authentication dependencies for FastAPI."""

import uuid
from typing import Optional

from fastapi import Depends, Header, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.jwt import decode_access_token
from app.auth.models import RefreshToken, User
from app.auth.service import AuthService
from app.common.exceptions import AuthorizationError, NotFoundError
from app.database import get_db
from app.households.models import HouseholdMember

_bearer = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(_bearer),
    db: AsyncSession = Depends(get_db),
) -> User:
    """Get current authenticated user from JWT token."""
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing or invalid authorization header",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = credentials.credentials

    try:
        payload = decode_access_token(token)
        user_id = uuid.UUID(payload["sub"])
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    stmt = select(User).where(User.id == user_id)
    user = await db.scalar(stmt)

    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return user


async def get_current_membership(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    household_id: Optional[uuid.UUID] = Header(None, alias="X-Household-ID"),
) -> HouseholdMember:
    """Resolve a selected household only through an active membership."""
    stmt = select(HouseholdMember).where(
        HouseholdMember.user_id == current_user.id,
        HouseholdMember.is_active.is_(True),
    )
    if household_id is not None:
        stmt = stmt.where(HouseholdMember.household_id == household_id)
    stmt = stmt.order_by(HouseholdMember.joined_at, HouseholdMember.id)
    member = await db.scalar(stmt)
    if not member:
        raise HTTPException(status_code=404, detail="Household membership not found")
    return member


async def get_current_household_id(
    member: HouseholdMember = Depends(get_current_membership),
) -> uuid.UUID:
    return member.household_id


async def get_current_household_member_id(
    member: HouseholdMember = Depends(get_current_membership),
) -> uuid.UUID:
    return member.id


async def get_auth_service(db: AsyncSession = Depends(get_db)) -> AuthService:
    """Get auth service instance."""
    return AuthService(db)