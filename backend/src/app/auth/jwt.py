"""JWT encoding and decoding using PyJWT."""

import uuid
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Optional

import jwt
from jwt.exceptions import InvalidTokenError

from app.config import settings


def load_private_key() -> str:
    """Load RSA private key from file."""
    with open(settings.JWT_PRIVATE_KEY_PATH, "r") as f:
        return f.read()


def load_public_key() -> str:
    """Load RSA public key from file."""
    with open(settings.JWT_PUBLIC_KEY_PATH, "r") as f:
        return f.read()


def create_access_token(
    user_id: uuid.UUID,
    household_id: uuid.UUID,
    expires_delta: Optional[timedelta] = None,
) -> str:
    """Create JWT access token.

    Args:
        user_id: User UUID
        household_id: Household UUID
        expires_delta: Optional custom expiration

    Returns:
        Encoded JWT access token
    """
    if expires_delta is None:
        expires_delta = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

    now = datetime.now(timezone.utc)
    expire = now + expires_delta

    payload = {
        "sub": str(user_id),
        "household_id": str(household_id),
        "iat": now,
        "exp": expire,
        "type": "access",
    }

    private_key = load_private_key()
    return jwt.encode(payload, private_key, algorithm=settings.JWT_ALGORITHM)


def create_refresh_token() -> str:
    """Create opaque refresh token (random string)."""
    return uuid.uuid4().hex + uuid.uuid4().hex


def decode_access_token(token: str) -> dict:
    """Decode and validate JWT access token.

    Args:
        token: JWT access token

    Returns:
        Decoded token payload

    Raises:
        InvalidTokenError: If token is invalid or expired
    """
    public_key = load_public_key()
    try:
        payload = jwt.decode(
            token,
            public_key,
            algorithms=[settings.JWT_ALGORITHM],
        )
        return payload
    except InvalidTokenError as e:
        raise InvalidTokenError(f"Invalid access token: {e}") from e


def get_token_payload(token: str) -> Optional[dict]:
    """Get token payload without validation (for debugging)."""
    try:
        return jwt.decode(
            token,
            options={"verify_signature": False},
        )
    except Exception:
        return None