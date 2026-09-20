"""Password hashing using Argon2id via pwdlib."""

from pwdlib import PasswordHash


# Argon2id hasher with recommended parameters
password_hash = PasswordHash.recommended()


def hash_password(password: str) -> str:
    """Hash a password using Argon2id.

    Args:
        password: Plain text password

    Returns:
        Argon2id hash string
    """
    return password_hash.hash(password)


def verify_password(password: str, password_hash_str: str) -> bool:
    """Verify a password against its hash.

    Args:
        password: Plain text password
        password_hash_str: Stored hash string

    Returns:
        True if password matches, False otherwise
    """
    return password_hash.verify(password, password_hash_str)