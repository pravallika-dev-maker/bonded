from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ...database import get_db
from ..deps import get_current_user, get_active_relationship
from ...models.user import User
from ...models.separation import Separation
from ...schemas.separation import SeparationCreate, SeparationResponse, ActiveSeparationResponse
from ...services.notification_service import create_notification, create_notification_and_push, send_data_push
from datetime import datetime, date, timedelta, timezone

router = APIRouter(prefix="/separations", tags=["Separations"])

MOOD_PHRASES = {
    1: "Finding stillness",
    2: "Learning to breathe",
    3: "Sitting with yourself",
    4: "Quietly growing",
    5: "Beginning to understand",
    6: "Holding space",
    7: "A week of choosing space"
}

@router.post("/", response_model=SeparationResponse)
def create_separation(
    request: SeparationCreate, 
    current_user: User = Depends(get_current_user), 
    db: Session = Depends(get_db),
    active_rel = Depends(get_active_relationship)
):
    # Check if active separation already exists
    existing_sep = db.query(Separation).filter(
        (Separation.creator_id == current_user.id) | (Separation.partner_id == current_user.id),
        Separation.status == "active"
    ).first()
    
    if existing_sep:
        raise HTTPException(
            status_code=409,
            detail="An active separation already exists. You cannot create another one."
        )

    # Create Separation row
    start_d = datetime.fromisoformat(request.start_date.replace('Z', '+00:00')).date()
    
    # Calculate expected end date
    label = request.duration_label.lower()
    days_to_add = 7 # default
    if "week" in label:
        if "2" in label or "two" in label:
            days_to_add = 14
    elif "month" in label:
        days_to_add = 30
    elif "day" in label:
        import re
        match = re.search(r'(\d+)', label)
        if match:
            days_to_add = int(match.group(1))
            
    expected_end_d = start_d + timedelta(days=days_to_add)
    
    new_sep = Separation(
        creator_id=current_user.id,
        partner_id=current_user.partner_id,
        relationship_id=active_rel.id if active_rel else None,
        duration_label=request.duration_label,
        start_date=start_d,
        expected_end_date=expected_end_d,
        reason=request.reason
    )
    db.add(new_sep)
    db.commit()
    db.refresh(new_sep)
    
    # Notify partner
    if current_user.partner_id:
        partner = db.query(User).filter(User.id == current_user.partner_id).first()
        create_notification_and_push(
            db, 
            recipient_id=current_user.partner_id, 
            notification_type="separation_started", 
            title="🌿 Space has begun", 
            body=f"{current_user.user_name or 'Your partner'} started a separation.",
            fcm_token=partner.fcm_token if partner else None
        )
        
    partner_name = None
    if current_user.partner_id:
        partner = db.query(User).filter(User.id == current_user.partner_id).first()
        if partner:
            partner_name = current_user.partner_name or partner.user_name
            
    # Convert to response — day 1 is the start date itself (1-based, same as reflections)
    new_sep.days_elapsed = (date.today() - new_sep.start_date).days + 1
    new_sep.partner_name = partner_name
    return new_sep

@router.get("/active", response_model=ActiveSeparationResponse)
def get_active_separation(
    current_user: User = Depends(get_current_user), 
    db: Session = Depends(get_db),
    active_rel = Depends(get_active_relationship)
):
    # 1. Query where (creator_id = user.id OR partner_id = user.id) AND status = "active"
    sep = db.query(Separation).filter(
        (Separation.creator_id == current_user.id) | (Separation.partner_id == current_user.id),
        Separation.status == "active"
    ).order_by(Separation.created_at.desc()).first()
    
    if not sep:
        return ActiveSeparationResponse(is_active=False)
        
    # 2. Compute days_elapsed — 1-based so Day 1 = start date, Day 2 = day after, etc.
    #    This is consistent with how reflections.py calculates day_number (elapsed + 1).
    days = (date.today() - sep.start_date).days + 1
    if days < 1:
        days = 1  # guard against future start_date
        
    # 3. Compute mood_phrase from day number
    phrase = MOOD_PHRASES.get(days, "Continuing to grow")
    
    # Resolve partner_name: try live partner record first, then onboarding fallback
    partner_name = current_user.partner_name  # onboarding fallback
    other_user_id = sep.partner_id if sep.creator_id == current_user.id else sep.creator_id
    if other_user_id:
        other_user = db.query(User).filter(User.id == other_user_id).first()
        if other_user and other_user.user_name and not partner_name:
            partner_name = other_user.user_name
            
    return ActiveSeparationResponse(
        is_active=True,
        id=sep.id,
        duration_label=sep.duration_label,
        start_date=sep.start_date,
        expected_end_date=sep.expected_end_date,
        reason=sep.reason,
        days_elapsed=days,
        mood_phrase=phrase,
        partner_name=partner_name
    )

@router.patch("/{id}/end")
def end_separation(id: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    sep = db.query(Separation).filter(
        Separation.id == id,
        (Separation.creator_id == current_user.id) | (Separation.partner_id == current_user.id)
    ).first()
    
    if not sep:
        raise HTTPException(status_code=404, detail="Separation not found")
        
    sep.status = "completed"
    sep.ended_at = datetime.now(timezone.utc)
    db.commit()
    
    partner_to_notify = sep.partner_id if current_user.id == sep.creator_id else sep.creator_id
    if partner_to_notify:
        partner = db.query(User).filter(User.id == partner_to_notify).first()
        create_notification_and_push(
            db,
            recipient_id=partner_to_notify,
            notification_type="separation_ended",
            title="Separation Completed",
            body="🌅 Your separation journey has reached its final chapter.",
            fcm_token=partner.fcm_token if partner else None
        )
        create_notification_and_push(
            db,
            recipient_id=partner_to_notify,
            notification_type="insight_unlocked",
            title="Insight Ready",
            body="🔓 Your shared journey insight is ready.",
            fcm_token=partner.fcm_token if partner else None
        )
        
    create_notification_and_push(
        db,
        recipient_id=current_user.id,
        notification_type="separation_ended",
        title="Separation Completed",
        body="🌅 Your separation journey has reached its final chapter.",
        fcm_token=current_user.fcm_token
    )
    create_notification_and_push(
        db,
        recipient_id=current_user.id,
        notification_type="insight_unlocked",
        title="Insight Ready",
        body="🔓 Your shared journey insight is ready.",
        fcm_token=current_user.fcm_token
    )

    return {"success": True, "message": "Separation ended successfully"}

@router.post("/time-travel")
def time_travel_separation(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    try:
        sep = db.query(Separation).filter(
            (Separation.creator_id == current_user.id) | (Separation.partner_id == current_user.id),
            Separation.status == "active"
        ).order_by(Separation.created_at.desc()).first()
        
        if not sep:
            raise HTTPException(status_code=404, detail="No active separation found")
            
        new_end = date.today()
        
        # Recalculate duration from label to fix any corrupted dates
        duration = 7
        if sep.duration_label:
            label = sep.duration_label.lower()
            if "week" in label:
                if "2" in label or "two" in label:
                    duration = 14
            elif "month" in label:
                duration = 30
            elif "day" in label:
                import re
                match = re.search(r'(\d+)', label)
                if match:
                    duration = int(match.group(1))
            else:
                if sep.expected_end_date and sep.start_date:
                    duration = (sep.expected_end_date - sep.start_date).days
        elif sep.expected_end_date and sep.start_date:
            duration = (sep.expected_end_date - sep.start_date).days
            
        new_start = new_end - timedelta(days=duration - 1)
        
        sep.start_date = new_start
        sep.expected_end_date = new_end
        
        # Generate dummy reflections and moods for the past `duration` days
        from ...models.reflection_session import ReflectionSession
        from ...models.mood import Mood
        import random
        
        for i in range(1, duration + 1):
            past_date = new_start + timedelta(days=i-1)
            past_datetime = datetime.combine(past_date, datetime.min.time()).replace(tzinfo=timezone.utc)
            
            existing_session = db.query(ReflectionSession).filter(
                ReflectionSession.user_id == current_user.id,
                ReflectionSession.separation_id == sep.id,
                ReflectionSession.day_number == i
            ).first()
            if not existing_session:
                dummy_session = ReflectionSession(
                    user_id=current_user.id,
                    separation_id=sep.id,
                    day_number=i,
                    is_completed=True,
                    completed_at=past_datetime
                )
                db.add(dummy_session)
                
        other_user_id = sep.partner_id if sep.creator_id == current_user.id else sep.creator_id
        if other_user_id:
            for i in range(1, duration + 1):
                past_date = new_start + timedelta(days=i-1)
                past_datetime = datetime.combine(past_date, datetime.min.time()).replace(tzinfo=timezone.utc)
                
                existing_session = db.query(ReflectionSession).filter(
                    ReflectionSession.user_id == other_user_id,
                    ReflectionSession.separation_id == sep.id,
                    ReflectionSession.day_number == i
                ).first()
                if not existing_session:
                    dummy_session = ReflectionSession(
                        user_id=other_user_id,
                        separation_id=sep.id,
                        day_number=i,
                        is_completed=True,
                        completed_at=past_datetime
                    )
                    db.add(dummy_session)

        db.commit()

        # ── Mark as completed so users can start a fresh separation ──
        sep.status = "completed"
        sep.ended_at = datetime.now(timezone.utc)
        db.commit()

        # ── Cross-device sync: silently notify the partner to refresh insights ──
        other_user_id_final = sep.partner_id if sep.creator_id == current_user.id else sep.creator_id
        
        for uid in [current_user.id, other_user_id_final]:
            if uid:
                u = db.query(User).filter(User.id == uid).first()
                if u and u.fcm_token:
                    create_notification_and_push(
                        db,
                        recipient_id=u.id,
                        notification_type="separation_ended",
                        title="Separation Completed",
                        body="🌅 Your separation journey has reached its final chapter.",
                        fcm_token=u.fcm_token
                    )
                    create_notification_and_push(
                        db,
                        recipient_id=u.id,
                        notification_type="insight_unlocked",
                        title="Insight Ready",
                        body="🔓 Your shared journey insight is ready.",
                        fcm_token=u.fcm_token
                    )
                    
        if other_user_id_final:
            partner_user = db.query(User).filter(User.id == other_user_id_final).first()
            if partner_user and partner_user.fcm_token:
                send_data_push(
                    partner_user.fcm_token,
                    {
                        "type": "time_travel_completed",
                        "separation_id": str(sep.id),
                    }
                )

        return {"success": True, "message": "Time travel successful! Separation marked complete."}
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Time travel error: {str(e)}")
