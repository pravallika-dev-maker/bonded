from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api import deps
from app.schemas.drift_bottle import DriftBottleStatusResponse, UserRewardsResponse, DriftBottleOpenResponse
from app.services import drift_bottle_service
from app.models.user import User

router = APIRouter()

@router.get("/status", response_model=DriftBottleStatusResponse)
def get_drift_bottle_status(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    """
    Get the current status of the daily drift bottle for the logged-in user.
    """
    return drift_bottle_service.get_drift_bottle_status(db=db, user_id=current_user.id)

@router.get("/rewards", response_model=UserRewardsResponse)
def get_drift_bottle_rewards(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    """
    Get the total rewards (love tokens and aura fragments) for the logged-in user.
    """
    return drift_bottle_service.get_user_rewards(db=db, user_id=current_user.id)

@router.post("/open", response_model=DriftBottleOpenResponse)
def open_drift_bottle(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    """
    Open today's drift bottle for the logged-in user.
    """
    response = drift_bottle_service.open_drift_bottle(db=db, user_id=current_user.id)
    if not response.success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=response.message
        )
    return response
