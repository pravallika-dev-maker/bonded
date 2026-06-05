from fastapi import APIRouter, Depends, HTTPException, status
import logging
from datetime import datetime
from sqlalchemy.orm import Session
from ...database import get_db
from ...schemas.user import UserProfileUpdate
from ...models.user import User
from ..deps import get_current_user

logger = logging.getLogger("bonded.users")

router = APIRouter(prefix="/users", tags=["users"])

@router.get("/me")
async def get_my_profile(current_user: User = Depends(get_current_user)):
    return {
        "success": True,
        "data": {
            "id": current_user.id,
            "phoneNumber": current_user.phone_number,
            "userName": current_user.user_name,
            "relationType": current_user.relation_type,
            "partnerName": current_user.partner_name,
            "relationshipDate": current_user.relationship_date.isoformat() if current_user.relationship_date else None,
            "dob": current_user.dob.isoformat() if current_user.dob else None,
            "gender": current_user.gender,
            "partnerId": current_user.partner_id,
            "isPartnerConnected": current_user.partner_id is not None,
        }
    }

@router.patch("/profile")
async def update_profile(
    profile_data: UserProfileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    logger.info(f"--- INCOMING PROFILE DATA: {profile_data.model_dump()} ---")
    # Update fields if provided
    if profile_data.userName is not None:
        current_user.user_name = profile_data.userName
    if profile_data.relationType is not None:
        current_user.relation_type = profile_data.relationType
    if profile_data.partnerName is not None:
        current_user.partner_name = profile_data.partnerName
    if profile_data.gender is not None:
        current_user.gender = profile_data.gender
    
    if profile_data.relationshipDate is not None:
        try:
            current_user.relationship_date = datetime.strptime(profile_data.relationshipDate, "%Y-%m-%d").date()
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid relationshipDate format. Use YYYY-MM-DD")
            
    if profile_data.dob is not None:
        try:
            current_user.dob = datetime.strptime(profile_data.dob, "%Y-%m-%d").date()
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid dob format. Use YYYY-MM-DD")
        
    db.commit()
    db.refresh(current_user)
    
    return {"message": "Profile updated successfully", "success": True}

@router.delete("/me")
async def delete_my_account(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Permanently deletes the current user's profile and all associated data,
    including moods, letters, reflection sessions, answers, comparisons,
    invite codes, and separations.
    Safely handles self-referencing and partner linkages to prevent foreign key violations.
    """
    uid = current_user.id
    
    # 1. Handle partner linkage first: find any user who has partner_id == current_user.id
    # Nullify their partner_id and set is_partnered=False so they don't break/crash
    partner = db.query(User).filter(User.partner_id == uid).first()
    if partner:
        partner.partner_id = None
        partner.is_partnered = False
        
    # Nullify current user's partner_id as well before deleting
    current_user.partner_id = None
    db.commit()

    # 2. Delete related records sequentially to avoid FK constraint errors:
    
    # A. Delete Invite codes
    from ...models.invite_code import InviteCode
    db.query(InviteCode).filter(InviteCode.creator_id == uid).delete(synchronize_session=False)

    # B. Delete Notifications
    from ...models.notification import Notification
    db.query(Notification).filter(Notification.recipient_id == uid).delete(synchronize_session=False)

    # C. Delete Moods
    from ...models.mood import Mood
    db.query(Mood).filter(Mood.user_id == uid).delete(synchronize_session=False)

    # D. Delete Letters (where user is author OR partner)
    from ...models.letter import Letter
    db.query(Letter).filter((Letter.author_id == uid) | (Letter.partner_id == uid)).delete(synchronize_session=False)

    # E. Delete Reflection Answers
    from ...models.reflection_answer import ReflectionAnswer
    db.query(ReflectionAnswer).filter(ReflectionAnswer.user_id == uid).delete(synchronize_session=False)

    # F. Delete Reflection Sessions & their Comparisons
    from ...models.reflection_session import ReflectionSession
    from ...models.reflection_comparison import ReflectionComparison
    
    session_ids = [s.id for s in db.query(ReflectionSession).filter(ReflectionSession.user_id == uid).all()]
    if session_ids:
        db.query(ReflectionComparison).filter(
            (ReflectionComparison.user_a_session_id.in_(session_ids)) | 
            (ReflectionComparison.user_b_session_id.in_(session_ids))
        ).delete(synchronize_session=False)
        
    db.query(ReflectionSession).filter(ReflectionSession.user_id == uid).delete(synchronize_session=False)

    # G. Delete Separations & their Comparisons (by separation_id)
    from ...models.separation import Separation
    sep_ids = [s.id for s in db.query(Separation).filter((Separation.creator_id == uid) | (Separation.partner_id == uid)).all()]
    if sep_ids:
        db.query(ReflectionComparison).filter(ReflectionComparison.separation_id.in_(sep_ids)).delete(synchronize_session=False)
        db.query(Separation).filter(Separation.id.in_(sep_ids)).delete(synchronize_session=False)

    db.commit()

    db.query(User).filter(User.id == uid).delete(synchronize_session=False)
    db.commit()

    return {"message": "Account and all associated data permanently deleted.", "success": True}

from ...schemas.user import FCMTokenUpdate

@router.post("/fcm-token")
async def register_fcm_token(
    data: FCMTokenUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    current_user.fcm_token = data.fcmToken
    db.commit()
    logger.info(f"Registered FCM token for user {current_user.id}: {data.fcmToken[:15]}...")
    return {"success": True, "message": "FCM token registered successfully"}

