"""Authentication router."""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.dependencies import get_auth_service, get_current_user, get_current_household_member_id
from app.auth.schemas import LoginRequest, PasswordResetConfirmRequest, PasswordResetRequest, RefreshRequest, RegisterRequest, TokenResponse
from app.auth.service import AuthService
from app.database import get_db

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register(
    data: RegisterRequest,
    auth_service: AuthService = Depends(get_auth_service),
):
    """Register a new user and create household."""
    return await auth_service.register(data)


@router.post("/login", response_model=TokenResponse)
async def login(
    data: LoginRequest,
    auth_service: AuthService = Depends(get_auth_service),
):
    """Login with email and password."""
    return await auth_service.login(data)


@router.post("/token", response_model=TokenResponse)
async def create_token(
    # OAuth2 compatible token endpoint
    data: LoginRequest,
    auth_service: AuthService = Depends(get_auth_service),
):
    """Obtain access token (OAuth2 compatible)."""
    return await auth_service.login(data)


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    data: RefreshRequest,
    auth_service: AuthService = Depends(get_auth_service),
):
    """Refresh access token."""
    return await auth_service.refresh(data.refresh_token)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(
    data: RefreshRequest,
    auth_service: AuthService = Depends(get_auth_service),
):
    """Logout (revoke refresh token)."""
    await auth_service.logout(data.refresh_token)


@router.post("/password-reset", status_code=status.HTTP_202_ACCEPTED)
async def request_password_reset(
    data: PasswordResetRequest,
    auth_service: AuthService = Depends(get_auth_service),
):
    """Request password reset (stub: returns 202 in v1)."""
    await auth_service.request_password_reset(data)


@router.post("/password-reset/confirm", status_code=status.HTTP_501_NOT_IMPLEMENTED)
async def confirm_password_reset(
    data: PasswordResetConfirmRequest,
    auth_service: AuthService = Depends(get_auth_service),
):
    """Confirm password reset (stub: returns 501 in v1)."""
    await auth_service.confirm_password_reset(data)
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Not implemented in v1",
    )


@router.get("/me")
async def get_current_user_info(
    current_user = Depends(get_current_user),
):
    """Get current user info."""
    return {
        "id": str(current_user.id),
        "email": current_user.email,
        "is_active": current_user.is_active,
        "email_verified": current_user.email_verified,
        "created_at": current_user.created_at.isoformat(),
    }