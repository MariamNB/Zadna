"""Audit log router (admin/internal only)."""

import uuid
from typing import List, Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.dependencies import get_current_household_id
from app.audit.models import AuditLog
from app.audit.schemas import AuditLogResponse
from app.audit.service import AuditService
from app.database import get_db

router = APIRouter(prefix="/audit-logs", tags=["Audit Logs"])


async def get_audit_service(db: AsyncSession = Depends(get_db)) -> AuditService:
    return AuditService(db)


@router.get("", response_model=List[AuditLogResponse])
async def get_audit_logs(
    entity_type: Optional[str] = Query(None),
    entity_id: Optional[uuid.UUID] = Query(None),
    limit: int = Query(100, ge=1, le=1000),
    household_id: uuid.UUID = Depends(get_current_household_id),
    service: AuditService = Depends(get_audit_service),
):
    """Get audit logs for the current household (admin/internal)."""
    logs = await service.get_audit_logs(household_id, entity_type, entity_id, limit)
    return logs