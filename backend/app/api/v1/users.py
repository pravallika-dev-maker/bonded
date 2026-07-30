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
async def get_my_profile(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    is_connected = current_user.partner_id is not None

    # Resolve partner name:
    # - If connected: prefer live partner's user_name, fall back to onboarding partner_name
    # - If not connected: return onboarding partner_name (collected during profile setup)
    partner = None
    if is_connected:
        partner = db.query(User).filter(User.id == current_user.partner_id).first()

    partner_name = current_user.partner_name
    if not partner_name and is_connected and partner:
        partner_name = partner.user_name

    # Merge logic for missing fields
    if is_connected and partner:
        relation_type = current_user.relation_type or partner.relation_type
        relationship_date = current_user.relationship_date or partner.relationship_date
    else:
        relation_type = current_user.relation_type
        relationship_date = current_user.relationship_date

    # Only expose activeRelationship and relationshipScore when actively connected
    active_rel_data = None
    if is_connected and partner:
        active_rel_data = {
            "partnerName": partner_name,
            "gender": partner.gender,
            "relationType": relation_type,
            "relationshipDate": relationship_date.isoformat() if relationship_date else None,
            "relationshipScore": current_user.relationship_score
        }

    return {
        "success": True,
        "data": {
            "id": current_user.id,
            "phoneNumber": current_user.phone_number,
            "userName": current_user.user_name,
            "gender": current_user.gender,
            "partnerId": current_user.partner_id,
            "isPartnerConnected": is_connected,
            "partnerName": partner_name,
            "relationType": relation_type,
            "relationshipDate": relationship_date.isoformat() if relationship_date else None,
            "relationshipScore": current_user.relationship_score if is_connected else None,
            "notificationsEnabled": current_user.notifications_enabled,
            "activeRelationship": active_rel_data
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
    if profile_data.notificationsEnabled is not None:
        current_user.notifications_enabled = profile_data.notificationsEnabled
    
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
        
    try:
        db.commit()
        db.refresh(current_user)
        return {"message": "Profile updated successfully", "success": True}
    except Exception as e:
        db.rollback()
        logger.error(f"Database error in update_profile: {e}")
        raise HTTPException(status_code=500, detail="An internal error occurred. Please try again.")

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
    try:
        # A. Delete Invite codes
        from ...models.invite_code import InviteCode
        db.query(InviteCode).filter(InviteCode.creator_id == uid).delete(synchronize_session=False)

        # B. Delete Notifications
        from ...models.notification import Notification
        db.query(Notification).filter(Notification.recipient_id == uid).delete(synchronize_session=False)

        # C. Delete Moods
        from ...models.mood import Mood
        db.query(Mood).filter(Mood.user_id == uid).delete(synchronize_session=False)

        # D. Delete Letters
        from ...models.letter import Letter
        db.query(Letter).filter((Letter.author_id == uid) | (Letter.partner_id == uid)).delete(synchronize_session=False)

        # E. Delete Reflection Answers
        from ...models.reflection_answer import ReflectionAnswer
        db.query(ReflectionAnswer).filter(ReflectionAnswer.user_id == uid).delete(synchronize_session=False)

        # F. Delete Reflection Sessions & Comparisons
        from ...models.reflection_session import ReflectionSession
        from ...models.reflection_comparison import ReflectionComparison
        
        session_ids = [s.id for s in db.query(ReflectionSession).filter(ReflectionSession.user_id == uid).all()]
        if session_ids:
            db.query(ReflectionComparison).filter(
                (ReflectionComparison.user_a_session_id.in_(session_ids)) | 
                (ReflectionComparison.user_b_session_id.in_(session_ids))
            ).delete(synchronize_session=False)
            
        db.query(ReflectionSession).filter(ReflectionSession.user_id == uid).delete(synchronize_session=False)

        # G. Delete Separations & their Comparisons
        from ...models.separation import Separation
        sep_ids = [s.id for s in db.query(Separation).filter((Separation.creator_id == uid) | (Separation.partner_id == uid)).all()]
        if sep_ids:
            db.query(ReflectionComparison).filter(ReflectionComparison.separation_id.in_(sep_ids)).delete(synchronize_session=False)
            db.query(Separation).filter(Separation.id.in_(sep_ids)).delete(synchronize_session=False)

        # H. Delete Relationships
        from ...models.relationship import Relationship
        db.query(Relationship).filter((Relationship.user1_id == uid) | (Relationship.user2_id == uid)).delete(synchronize_session=False)

        # I. Delete Daily Content
        try:
            from ...models.user_daily_affirmation import UserDailyAffirmation
            from ...models.user_daily_comfort import UserDailyComfort
            from ...models.user_daily_insight import UserDailyInsight
            db.query(UserDailyAffirmation).filter(UserDailyAffirmation.user_id == uid).delete(synchronize_session=False)
            db.query(UserDailyComfort).filter(UserDailyComfort.user_id == uid).delete(synchronize_session=False)
            db.query(UserDailyInsight).filter(UserDailyInsight.user_id == uid).delete(synchronize_session=False)
        except ImportError as e:
            logger.warning(f"Skipped deleting some daily content due to import error: {e}")
            pass

        db.commit()

        db.query(User).filter(User.id == uid).delete(synchronize_session=False)
        db.commit()

        return {"message": "Account and all associated data permanently deleted.", "success": True}
    except Exception as e:
        db.rollback()
        logger.error(f"Database error in delete_my_account: {e}")
        raise HTTPException(status_code=500, detail=f"Error deleting account: {str(e)}")

from ...schemas.user import FCMTokenUpdate

@router.post("/fcm-token")
async def register_fcm_token(
    data: FCMTokenUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        current_user.fcm_token = data.fcmToken
        db.commit()
        logger.info(f"Registered FCM token for user {current_user.id}: {data.fcmToken[:15]}...")
        return {"success": True, "message": "FCM token registered successfully"}
    except Exception as e:
        db.rollback()
        logger.error(f"Database error in register_fcm_token: {e}")
        raise HTTPException(status_code=500, detail="An internal error occurred. Please try again.")

@router.post("/welcome-push")
async def send_welcome_push(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    from ...services.notification_service import create_notification_and_push
    if current_user.fcm_token:
        create_notification_and_push(
            db=db,
            recipient_id=current_user.id,
            notification_type="system",
            title="Welcome to Bonded ✨",
            body="We are so glad you are here! Start your journey with your partner.",
            fcm_token=current_user.fcm_token
        )
        return {"success": True}
    return {"success": False, "message": "No FCM token"}
