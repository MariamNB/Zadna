"""Household service."""

import uuid
from typing import Optional
from datetime import datetime, timedelta, timezone

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.households.models import Household, HouseholdMember, HouseholdInvitation
from app.households.schemas import HouseholdResponse, HouseholdMemberResponse
from app.storage.models import StorageLocation
from app.auth.models import User
from app.common.exceptions import ConflictError, ForbiddenError, NotFoundError, ValidationError
from app.households.schemas import InvitationCreate, InvitationResponse, HouseholdMembershipResponse


class HouseholdService:
    """Household service."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def create_household_for_user(self, user_id: uuid.UUID) -> Household:
        """Create household with owner membership and default storage locations."""
        household = Household(
            name=f"User's Household",
            timezone="UTC",
        )
        self.session.add(household)
        await self.session.flush()

        # Create membership with owner role
        membership = HouseholdMember(
            household_id=household.id,
            user_id=user_id,
            role="owner",
        )
        self.session.add(membership)
        await self.session.flush()

        # Create default storage locations
        default_locations = [
            StorageLocation(
                household_id=household.id,
                name="Fridge",
                type="fridge",
                sort_order=1,
                created_by=membership.id,
                updated_by=membership.id,
            ),
            StorageLocation(
                household_id=household.id,
                name="Freezer",
                type="freezer",
                sort_order=2,
                created_by=membership.id,
                updated_by=membership.id,
            ),
            StorageLocation(
                household_id=household.id,
                name="Pantry",
                type="pantry",
                sort_order=3,
                created_by=membership.id,
                updated_by=membership.id,
            ),
        ]
        for loc in default_locations:
            self.session.add(loc)

        await self.session.flush()
        return household

    async def get_household(self, household_id: uuid.UUID) -> Optional[Household]:
        """Get household by ID."""
        stmt = select(Household).where(Household.id == household_id)
        return await self.session.scalar(stmt)

    async def get_household_by_member_id(self, member_id: uuid.UUID) -> Optional[Household]:
        """Get household by member ID."""
        stmt = (
            select(Household)
            .join(HouseholdMember, Household.id == HouseholdMember.household_id)
            .where(HouseholdMember.id == member_id)
        )
        return await self.session.scalar(stmt)

    async def list_members(self, household_id: uuid.UUID) -> list[HouseholdMember]:
        """List all members of a household."""
        stmt = (
            select(HouseholdMember)
            .where(HouseholdMember.household_id == household_id, HouseholdMember.is_active.is_(True))
            .options(selectinload(HouseholdMember.user))
            .order_by(HouseholdMember.joined_at)
        )
        result = await self.session.scalars(stmt)
        return list(result.all())

    async def list_households(self, user_id: uuid.UUID) -> list[HouseholdMembershipResponse]:
        members = await self.session.scalars(
            select(HouseholdMember).where(
                HouseholdMember.user_id == user_id, HouseholdMember.is_active.is_(True),
            ).options(selectinload(HouseholdMember.household))
            .order_by(HouseholdMember.joined_at, HouseholdMember.id)
        )
        return [HouseholdMembershipResponse(
            **HouseholdResponse.model_validate(m.household).model_dump(),
            role=m.role, member_id=m.id,
        ) for m in members]

    async def _lock_household(self, household_id: uuid.UUID) -> None:
        await self.session.scalar(select(Household).where(
            Household.id == household_id,
        ).with_for_update())

    async def _manager(self, actor: HouseholdMember, owner_only: bool = False) -> None:
        # Refresh permissions under the same household lock used by mutations.
        await self._lock_household(actor.household_id)
        await self.session.refresh(actor)
        roles = {"owner"} if owner_only else {"owner", "admin"}
        if not actor.is_active or actor.role not in roles:
            raise ForbiddenError("You do not have permission to manage this household")

    async def rename(self, actor: HouseholdMember, name: str) -> Household:
        await self._manager(actor)
        name = name.strip()
        if not name:
            raise ValidationError("Household name cannot be empty")
        household = await self.get_household(actor.household_id)
        household.name = name
        await self.session.flush()
        return household

    async def invitations(self, user: User = None, household_id: uuid.UUID = None):
        stmt = select(HouseholdInvitation, Household.name).join(
            Household, Household.id == HouseholdInvitation.household_id,
        ).where(
            HouseholdInvitation.status == "pending",
            HouseholdInvitation.expires_at > datetime.now(timezone.utc),
        )
        if user is not None:
            stmt = stmt.where(HouseholdInvitation.email == user.email.lower())
        else:
            stmt = stmt.where(HouseholdInvitation.household_id == household_id)
        rows = await self.session.execute(stmt.order_by(HouseholdInvitation.created_at.desc()))
        return [self._invitation_response(invite, name) for invite, name in rows]

    @staticmethod
    def _invitation_response(invite, name):
        return InvitationResponse(
            id=invite.id, household_id=invite.household_id, household_name=name,
            email=invite.email, role=invite.role, status=invite.status,
            expires_at=invite.expires_at,
        )

    async def invite(self, actor: HouseholdMember, data: InvitationCreate):
        await self._manager(actor, owner_only=data.role == "admin")
        email = str(data.email).lower()
        existing = await self.session.scalar(select(HouseholdMember).join(User).where(
            HouseholdMember.household_id == actor.household_id,
            HouseholdMember.is_active.is_(True), func.lower(User.email) == email,
        ))
        if existing:
            raise ConflictError("This person is already a household member", code="ALREADY_MEMBER")
        pending = await self.session.scalar(select(HouseholdInvitation).where(
            HouseholdInvitation.household_id == actor.household_id,
            HouseholdInvitation.email == email,
            HouseholdInvitation.status == "pending",
            HouseholdInvitation.expires_at > datetime.now(timezone.utc),
        ))
        if pending:
            raise ConflictError("An invitation is already pending", code="INVITATION_PENDING")
        invitation = HouseholdInvitation(
            household_id=actor.household_id, email=email, role=data.role,
            invited_by=actor.id, expires_at=datetime.now(timezone.utc) + timedelta(days=7),
        )
        self.session.add(invitation)
        await self.session.flush()
        household = await self.get_household(actor.household_id)
        return self._invitation_response(invitation, household.name)

    async def respond(self, user: User, invitation_id: uuid.UUID, accept: bool):
        invitation = await self.session.scalar(select(HouseholdInvitation).where(
            HouseholdInvitation.id == invitation_id,
            HouseholdInvitation.email == user.email.lower(),
        ))
        if not invitation:
            raise NotFoundError("Invitation not found")
        # All invite/member mutations lock the household before the invitation.
        await self._lock_household(invitation.household_id)
        await self.session.refresh(invitation)
        if invitation.status != "pending" or invitation.expires_at <= datetime.now(timezone.utc):
            raise ConflictError("This invitation is no longer available", code="INVITATION_UNAVAILABLE")
        if accept:
            member = await self.session.scalar(select(HouseholdMember).where(
                HouseholdMember.household_id == invitation.household_id,
                HouseholdMember.user_id == user.id,
            ))
            if member is None:
                member = HouseholdMember(household_id=invitation.household_id,
                                         user_id=user.id, role=invitation.role)
                self.session.add(member)
            elif not member.is_active:
                member.is_active = True
                member.role = invitation.role
                member.joined_at = datetime.now(timezone.utc)
            invitation.status = "accepted"
        else:
            invitation.status = "declined"
        await self.session.flush()
        household = await self.get_household(invitation.household_id)
        return self._invitation_response(invitation, household.name)

    async def revoke(self, actor: HouseholdMember, invitation_id: uuid.UUID):
        await self._manager(actor)
        invitation = await self.session.scalar(select(HouseholdInvitation).where(
            HouseholdInvitation.id == invitation_id,
            HouseholdInvitation.household_id == actor.household_id,
        ))
        if not invitation:
            raise NotFoundError("Invitation not found")
        if actor.role != "owner" and invitation.role == "admin":
            raise ForbiddenError("Only the owner can manage admin invitations")
        if invitation.status != "pending":
            raise ConflictError("This invitation is no longer available")
        invitation.status = "revoked"
        await self.session.flush()

    async def change_role(self, actor: HouseholdMember, member_id: uuid.UUID, role: str):
        await self._manager(actor, owner_only=True)
        member = await self._member(actor.household_id, member_id)
        if member.role == "owner":
            raise ForbiddenError("The owner's role cannot be changed")
        member.role = role
        await self.session.flush()

    async def _member(self, household_id: uuid.UUID, member_id: uuid.UUID):
        member = await self.session.scalar(select(HouseholdMember).where(
            HouseholdMember.household_id == household_id,
            HouseholdMember.id == member_id, HouseholdMember.is_active.is_(True),
        ))
        if not member:
            raise NotFoundError("Member not found")
        return member

    async def remove_member(self, actor: HouseholdMember, member_id: uuid.UUID):
        if actor.id == member_id:
            await self._lock_household(actor.household_id)
            await self.session.refresh(actor)
        else:
            await self._manager(actor)
        member = await self._member(actor.household_id, member_id)
        if member.role == "owner":
            raise ForbiddenError("The owner cannot leave or be removed")
        if actor.id != member.id and actor.role == "admin" and member.role != "member":
            raise ForbiddenError("Admins can only remove ordinary members")
        # Keep author/audit foreign keys intact; access is revoked immediately.
        member.is_active = False
        await self.session.flush()
