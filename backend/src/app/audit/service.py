"""Audit log service."""

import uuid
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.audit.models import AuditLog


class AuditService:
    """Audit log service."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def log_create(
        self,
        household_id: uuid.UUID,
        actor_user_id: uuid.UUID,
        entity_type: str,
        entity_id: uuid.UUID,
        metadata: dict,
    ) -> AuditLog:
        """Log a create action."""
        audit = AuditLog(
            household_id=household_id,
            actor_user_id=actor_user_id,
            action="create",
            entity_type=entity_type,
            entity_id=entity_id,
            metadata=metadata,
        )
        self.session.add(audit)
        await self.session.flush()
        return audit

    async def log_update(
        self,
        household_id: uuid.UUID,
        actor_user_id: uuid.UUID,
        entity_type: str,
        entity_id: uuid.UUID,
        metadata: dict,
    ) -> AuditLog:
        """Log an update action."""
        audit = AuditLog(
            household_id=household_id,
            actor_user_id=actor_user_id,
            action="update",
            entity_type=entity_type,
            entity_id=entity_id,
            metadata=metadata,
        )
        self.session.add(audit)
        await self.session.flush()
        return audit

    async def log_delete(
        self,
        household_id: uuid.UUID,
        actor_user_id: uuid.UUID,
        entity_type: str,
        entity_id: uuid.UUID,
        metadata: dict,
    ) -> AuditLog:
        """Log a delete action."""
        audit = AuditLog(
            household_id=household_id,
            actor_user_id=actor_user_id,
            action="delete",
            entity_type=entity_type,
            entity_id=entity_id,
            metadata=metadata,
        )
        self.session.add(audit)
        await self.session.flush()
        return audit

    async def get_audit_logs(
        self,
        household_id: uuid.UUID,
        entity_type: Optional[str] = None,
        entity_id: Optional[uuid.UUID] = None,
        limit: int = 100,
    ) -> list[AuditLog]:
        """Get audit logs for a household."""
        stmt = select(AuditLog).where(AuditLog.household_id == household_id)

        if entity_type:
            stmt = stmt.where(AuditLog.entity_type == entity_type)
        if entity_id:
            stmt = stmt.where(AuditLog.entity_id == entity_id)

        stmt = stmt.order_by(AuditLog.created_at.desc()).limit(limit)

        result = await self.session.scalars(stmt)
        return list(result.all())