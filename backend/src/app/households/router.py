"""Household router."""

import uuid
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.dependencies import get_current_household_id, get_current_membership, get_current_user
from app.auth.models import User
from app.households.models import HouseholdMember
from app.households.schemas import HouseholdMemberResponse, HouseholdResponse
from app.households.schemas import HouseholdMembershipResponse, HouseholdUpdate, InvitationCreate, InvitationResponse, MemberRoleUpdate
from app.households.service import HouseholdService
from app.database import get_db

router = APIRouter(prefix="/household", tags=["Households"])


async def get_household_service(db: AsyncSession = Depends(get_db)) -> HouseholdService:
    return HouseholdService(db)


@router.get("", response_model=HouseholdResponse)
async def get_household(
    household_id: uuid.UUID = Depends(get_current_household_id),
    service: HouseholdService = Depends(get_household_service),
):
    """Get current household info."""
    household = await service.get_household(household_id)
    if not household:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Household not found",
        )
    return household


@router.get("/members", response_model=List[HouseholdMemberResponse])
async def list_household_members(
    household_id: uuid.UUID = Depends(get_current_household_id),
    service: HouseholdService = Depends(get_household_service),
):
    """List all members of the current household."""
    members = await service.list_members(household_id)
    return [HouseholdMemberResponse(
        **HouseholdMemberResponse.model_validate(member).model_dump(exclude={"email"}),
        email=member.user.email,
    ) for member in members]


@router.get("/available", response_model=List[HouseholdMembershipResponse])
async def available_households(user: User = Depends(get_current_user), service: HouseholdService = Depends(get_household_service)):
    return await service.list_households(user.id)


@router.patch("", response_model=HouseholdResponse)
async def rename_household(data: HouseholdUpdate, actor: HouseholdMember = Depends(get_current_membership), service: HouseholdService = Depends(get_household_service)):
    return await service.rename(actor, data.name)


@router.get("/invitations/incoming", response_model=List[InvitationResponse])
async def incoming_invitations(user: User = Depends(get_current_user), service: HouseholdService = Depends(get_household_service)):
    return await service.invitations(user=user)


@router.get("/invitations", response_model=List[InvitationResponse])
async def sent_invitations(actor: HouseholdMember = Depends(get_current_membership), service: HouseholdService = Depends(get_household_service)):
    if actor.role not in {"owner", "admin"}:
        from app.common.exceptions import ForbiddenError
        raise ForbiddenError("You do not have permission to manage invitations")
    return await service.invitations(household_id=actor.household_id)


@router.post("/invitations", response_model=InvitationResponse, status_code=201)
async def invite_member(data: InvitationCreate, actor: HouseholdMember = Depends(get_current_membership), service: HouseholdService = Depends(get_household_service)):
    return await service.invite(actor, data)


@router.post("/invitations/{invitation_id}/accept", response_model=InvitationResponse)
async def accept_invitation(invitation_id: uuid.UUID, user: User = Depends(get_current_user), service: HouseholdService = Depends(get_household_service)):
    return await service.respond(user, invitation_id, True)


@router.post("/invitations/{invitation_id}/decline", response_model=InvitationResponse)
async def decline_invitation(invitation_id: uuid.UUID, user: User = Depends(get_current_user), service: HouseholdService = Depends(get_household_service)):
    return await service.respond(user, invitation_id, False)


@router.delete("/invitations/{invitation_id}", status_code=204)
async def revoke_invitation(invitation_id: uuid.UUID, actor: HouseholdMember = Depends(get_current_membership), service: HouseholdService = Depends(get_household_service)):
    await service.revoke(actor, invitation_id)


@router.patch("/members/{member_id}", status_code=204)
async def change_member_role(member_id: uuid.UUID, data: MemberRoleUpdate, actor: HouseholdMember = Depends(get_current_membership), service: HouseholdService = Depends(get_household_service)):
    await service.change_role(actor, member_id, data.role)


@router.delete("/members/{member_id}", status_code=204)
async def remove_member(member_id: uuid.UUID, actor: HouseholdMember = Depends(get_current_membership), service: HouseholdService = Depends(get_household_service)):
    await service.remove_member(actor, member_id)
