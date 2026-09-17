"""Reference data router."""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.reference.schemas import ReferenceDataResponse
from app.reference.service import ReferenceService

router = APIRouter(prefix="/reference", tags=["Reference Data"])


async def get_reference_service(db: AsyncSession = Depends(get_db)) -> ReferenceService:
    return ReferenceService(db)


@router.get("", response_model=ReferenceDataResponse)
async def get_reference_data(
    service: ReferenceService = Depends(get_reference_service),
):
    """Get all reference data (categories and units)."""
    return await service.get_reference_data()