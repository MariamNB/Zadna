"""Cursor-based pagination utilities."""

import base64
import json
from dataclasses import dataclass
from typing import Any, Generic, Optional, TypeVar

from pydantic import BaseModel, Field


T = TypeVar("T")


@dataclass
class Cursor:
    """Pagination cursor with created_at and id for stable ordering."""

    created_at: str  # ISO format datetime
    id: str  # UUID string

    def encode(self) -> str:
        """Encode cursor to base64 string."""
        data = {"created_at": self.created_at, "id": self.id}
        json_str = json.dumps(data, separators=(",", ":"))
        return base64.urlsafe_b64encode(json_str.encode()).decode()

    @classmethod
    def decode(cls, token: str) -> "Cursor":
        """Decode cursor from base64 string."""
        json_str = base64.urlsafe_b64decode(token.encode()).decode()
        data = json.loads(json_str)
        return cls(created_at=data["created_at"], id=data["id"])


class PaginationParams(BaseModel):
    """Pagination query parameters."""

    limit: int = Field(default=50, ge=1, le=100, description="Maximum items per page")
    cursor: Optional[str] = Field(default=None, description="Pagination cursor")


class PaginationEnvelope(BaseModel, Generic[T]):
    """Pagination response envelope."""

    items: list[T]
    next_page_token: Optional[str] = None


def create_pagination_response(
    items: list[T],
    has_more: bool,
    last_item_created_at: Optional[str] = None,
    last_item_id: Optional[str] = None,
) -> PaginationEnvelope[T]:
    """Create pagination response envelope.

    Args:
        items: List of items for current page
        has_more: Whether there are more items
        last_item_created_at: Created at of last item (for cursor)
        last_item_id: ID of last item (for cursor)

    Returns:
        PaginationEnvelope with items and next_page_token
    """
    next_token = None
    if has_more and last_item_created_at and last_item_id:
        cursor = Cursor(created_at=last_item_created_at, id=last_item_id)
        next_token = cursor.encode()

    return PaginationEnvelope(items=items, next_page_token=next_token)