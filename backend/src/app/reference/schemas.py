"""Reference data schemas."""

from typing import List

from pydantic import BaseModel


class LocalizedLabel(BaseModel):
    """Localized label with key and labels."""

    key: str
    labels: dict[str, str]  # {"ar": "...", "en": "..."}


class ReferenceDataResponse(BaseModel):
    """Reference data response."""

    categories: List[LocalizedLabel]
    units: List[LocalizedLabel]