"""Authentication business logic."""

import uuid
from datetime import datetime, timedelta, timezone
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.auth.jwt import create_access_token, create_refresh_token
from app.auth.models import RefreshToken, User
from app.auth.passwords import hash_password, verify_password
from app.auth.schemas import LoginRequest, PasswordResetConfirmRequest, PasswordResetRequest, RegisterRequest, TokenResponse
from app.common.exceptions import AuthorizationError, ConflictError, NotFoundError, ValidationError
from app.config import settings


class AuthService:
    """Authentication service."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def register(self, data: RegisterRequest) -> TokenResponse:
        """Register a new user."""
        # Check if email already exists
        stmt = select(User).where(User.email == data.email)
        existing = await self.session.scalar(stmt)
        if existing:
            raise ConflictError("Email already registered", code="EMAIL_EXISTS")

        # Create user
        user = User(
            email=data.email,
            password_hash=hash_password(data.password),
        )
        self.session.add(user)
        await self.session.flush()

        # Create household and membership
        from app.households.service import HouseholdService
        household_service = HouseholdService(self.session)
        await household_service.create_household_for_user(user.id)

        # Create tokens
        return await self._create_token_response(user)

    async def login(self, data: LoginRequest) -> TokenResponse:
        """Login with email and password."""
        stmt = select(User).where(User.email == data.email)
        user = await self.session.scalar(stmt)

        if not user or not verify_password(data.password, user.password_hash):
            raise AuthorizationError("Invalid credentials", code="INVALID_CREDENTIALS")

        if not user.is_active:
            raise AuthorizationError("Account is disabled", code="ACCOUNT_DISABLED")

        return await self._create_token_response(user)

    async def refresh(self, refresh_token: str) -> TokenResponse:
        """Refresh access token using refresh token."""
        # Hash the provided refresh token to compare
        # For simplicity, we'll look up by hash - in production, store hash
        stmt = select(RefreshToken).where(RefreshToken.token_hash == refresh_token)
        token = await self.session.scalar(stmt)

        if not token:
            raise AuthorizationError("Invalid refresh token", code="INVALID_REFRESH_TOKEN")

        if token.revoked_at:
            raise AuthorizationError("Refresh token has been revoked", code="REFRESH_TOKEN_REVOKED")

        if token.expires_at < datetime.now(timezone.utc):
            raise AuthorizationError("Refresh token has expired", code="REFRESH_TOKEN_EXPIRED")

        # Rotate refresh token
        token.revoked_at = datetime.now(timezone.utc)
        await self.session.flush()

        # Get user
        stmt = select(User).where(User.id == token.user_id)
        user = await self.session.scalar(stmt)
        if not user or not user.is_active:
            raise AuthorizationError("User not found or inactive", code="USER_INACTIVE")

        return await self._create_token_response(user)

    async def logout(self, refresh_token: str) -> None:
        """Revoke refresh token."""
        stmt = select(RefreshToken).where(RefreshToken.token_hash == refresh_token)
        token = await self.session.scalar(stmt)

        if token:
            token.revoked_at = datetime.now(timezone.utc)
            await self.session.flush()

    async def request_password_reset(self, data: PasswordResetRequest) -> None:
        """Request password reset (stub for v1)."""
        # TODO: Implement email sending
        # For v1, just return without error but log it
        pass

    async def confirm_password_reset(self, data: PasswordResetConfirmRequest) -> None:
        """Confirm password reset (stub for v1)."""
        # TODO: Implement token verification and password update
        # For v1, just return without error
        pass

    async def _create_token_response(self, user: User) -> TokenResponse:
        """Create token response for user."""
        # Get user's household
        from app.households.models import HouseholdMember
        stmt = select(HouseholdMember).where(HouseholdMember.user_id == user.id)
        member = await self.session.scalar(stmt)

        if not member:
            raise AuthorizationError("User has no household", code="NO_HOUSEHOLD")

        # Create access token
        access_token = create_access_token(user.id, member.household_id)

        # Create refresh token
        refresh_token = create_refresh_token()
        refresh_token_obj = RefreshToken(
            token_hash=refresh_token,
            user_id=user.id,
            expires_at=datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
        )
        self.session.add(refresh_token_obj)
        await self.session.flush()

        return TokenResponse(
            access_token=access_token,
            expires_in=15 * 60,  # 15 minutes in seconds
            refresh_token=refresh_token,
        )