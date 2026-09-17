"""Custom application exceptions."""

from typing import Any, Optional


class AppException(Exception):
    """Base application exception."""

    def __init__(
        self,
        message: str,
        code: str,
        details: Optional[dict[str, Any]] = None,
    ):
        self.message = message
        self.code = code
        self.details = details or {}
        super().__init__(message)


class NotFoundError(AppException):
    """Resource not found."""

    def __init__(
        self,
        message: str = "Resource not found",
        code: str = "NOT_FOUND",
        details: Optional[dict[str, Any]] = None,
    ):
        super().__init__(message, code, details)


class ValidationError(AppException):
    """Validation error."""

    def __init__(
        self,
        message: str = "Validation error",
        code: str = "VALIDATION_ERROR",
        details: Optional[dict[str, Any]] = None,
    ):
        super().__init__(message, code, details)


class AuthorizationError(AppException):
    """Authorization error."""

    def __init__(
        self,
        message: str = "Unauthorized",
        code: str = "UNAUTHORIZED",
        details: Optional[dict[str, Any]] = None,
    ):
        super().__init__(message, code, details)


class ConflictError(AppException):
    """Resource conflict."""

    def __init__(
        self,
        message: str = "Conflict",
        code: str = "CONFLICT",
        details: Optional[dict[str, Any]] = None,
    ):
        super().__init__(message, code, details)


class ForbiddenError(AppException):
    """Forbidden access."""

    def __init__(
        self,
        message: str = "Forbidden",
        code: str = "FORBIDDEN",
        details: Optional[dict[str, Any]] = None,
    ):
        super().__init__(message, code, details)