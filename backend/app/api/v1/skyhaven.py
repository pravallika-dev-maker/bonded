from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from ...database import get_db
from ...schemas.sky_haven import SkyHavenIslandResponse, SkyHavenIslandStatus, SkyHavenAssetListResponse, PlaceObjectRequest, ReactObjectRequest, PlacedIslandObjectBase, SkyHavenReactionBase
from ...services import skyhaven_service
from ..deps import get_current_user, get_active_relationship

router = APIRouter()

@router.get("/island", response_model=SkyHavenIslandResponse)
def get_island(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
    relationship = Depends(get_active_relationship)
):
    if not relationship:
        raise HTTPException(status_code=400, detail="User is not in a relationship")
    return skyhaven_service.get_island_full(db, relationship.id, current_user.id)


@router.get("/status", response_model=SkyHavenIslandStatus)
def get_island_status(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
    relationship = Depends(get_active_relationship)
):
    if not relationship:
        raise HTTPException(status_code=400, detail="User is not in a relationship")
    return skyhaven_service.get_island_status(db, relationship.id, current_user.id)


@router.get("/assets", response_model=SkyHavenAssetListResponse)
def get_assets(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    assets = skyhaven_service.get_assets(db)
    return {"assets": assets}


@router.post("/place-object", response_model=PlacedIslandObjectBase)
def place_object(
    data: PlaceObjectRequest,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
    relationship = Depends(get_active_relationship)
):
    if not relationship:
        raise HTTPException(status_code=400, detail="User is not in a relationship")
    return skyhaven_service.place_object(db, relationship.id, current_user.id, data)


@router.post("/object/{object_id}/read-whisper")
def read_whisper(
    object_id: str,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
    relationship = Depends(get_active_relationship)
):
    if not relationship:
        raise HTTPException(status_code=400, detail="User is not in a relationship")
    return skyhaven_service.read_whisper(db, relationship.id, current_user.id, object_id)


@router.post("/object/{object_id}/react", response_model=SkyHavenReactionBase)
def react_object(
    object_id: str,
    data: ReactObjectRequest,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
    relationship = Depends(get_active_relationship)
):
    if not relationship:
        raise HTTPException(status_code=400, detail="User is not in a relationship")
    return skyhaven_service.react_object(db, relationship.id, current_user.id, object_id, data)
