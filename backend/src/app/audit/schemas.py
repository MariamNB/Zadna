"""Audit log schemas."""

import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class AuditLogResponse(BaseModel):
    """Audit log response schema."""

    id: uuid.UUID
    action: str
    entity_type: str
    entity_id: uuid.UUID
    metadata: dict = Field(..., serialization_alias="audit_metadata", validation_alias="audit_metadata")
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)