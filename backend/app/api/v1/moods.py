from fastapi import APIRouter, Depends, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timezone
import logging

from ...database import get_db
from ...schemas.mood import MoodCreate, MoodResponse
from ...models.mood import Mood
from ..deps import get_current_user
from ...models.user import User
from ...services.ai_service import generate_mood_insight, generate_self_insight
from ...services.notification_service import create_notification_and_push

logger = logging.getLogger("bonded.moods")

router = APIRouter(prefix="/moods", tags=["moods"])

async def _trigger_mood_notifications(user_id: int, partner_id: int, new_mood_id: int, db: Session):
    try:
        user = db.query(User).filter(User.id == user_id).first()
        new_mood = db.query(Mood).filter(Mood.id == new_mood_id).first()
        if not user or not new_mood:
            return
            
        # 1. Trigger 4: Self-discovery insight
        user_moods = db.query(Mood).filter(Mood.user_id == user_id).order_by(Mood.created_at.asc()).all()
        mood_list = [{"mood": m.mood, "reflection": m.reflection} for m in user_moods]
        insight_text = await generate_self_insight(mood_list)
        
        create_notification_and_push(
            db=db,
            recipient_id=user_id,
            notification_type="self_insight",
            title="Daily Insight",
            body="✨ Today's reflection has revealed something new.",
            fcm_token=user.fcm_token
        )
        
        # 2. Trigger 7: Partner mood logged
        if partner_id:
            partner = db.query(User).filter(User.id == partner_id).first()
            if partner:
                create_notification_and_push(
                    db=db,
                    recipient_id=partner_id,
                    notification_type="partner_mood",
                    title="Mood Check-In",
                    body="🌱 Your partner checked in with their feelings today.",
                    fcm_token=partner.fcm_token
                )
                
        # 3. Love Word Change Check
        try:
            from ...models.relationship import Relationship
            from ...models.separation import Separation
            from .journey import calculate_user_score, get_love_word, get_expected_days_for_sep
            
            active_rel = db.query(Relationship).filter(
                ((Relationship.user1_id == user.id) & (Relationship.user2_id == partner_id)) |
                ((Relationship.user1_id == partner_id) & (Relationship.user2_id == user.id)),
                Relationship.status == "active"
            ).first() if partner_id else None
            
            active_sep = db.query(Separation).filter(
                (Separation.creator_id == user.id) | (Separation.partner_id == user.id),
                Separation.status == "active"
            ).order_by(Separation.created_at.desc()).first()
            
            if active_rel and active_sep:
                expected_days = get_expected_days_for_sep(active_sep)
                old_user_score = user.relationship_score or 0
                old_partner_score = partner.relationship_score or 0 if partner_id and partner else 0
                old_total = old_user_score + old_partner_score
                
                new_user_score = calculate_user_score(db, user, active_rel, active_sep)
                new_partner_score = calculate_user_score(db, partner, active_rel, active_sep) if partner_id and partner else 0
                new_total = new_user_score + new_partner_score
                
                old_word = get_love_word(old_total, expected_days)["loveWord"]
                new_word_info = get_love_word(new_total, expected_days)
                new_word = new_word_info["loveWord"]
                
                if old_word != new_word:
                    msg = f"{new_word_info['emoji']} Your relationship has entered a new phase: {new_word}."
                    for u in [user, partner] if partner_id and partner else [user]:
                        if u and u.fcm_token:
                            create_notification_and_push(
                                db=db,
                                recipient_id=u.id,
                                notification_type="love_word_change",
                                title="Journey Milestone",
                                body=msg,
                                fcm_token=u.fcm_token
                            )
        except Exception as lw_e:
            logger.error(f"Error checking love word change: {lw_e}")
    except Exception as e:
        logger.error(f"Error in _trigger_mood_notifications: {e}")

@router.post("/", response_model=MoodResponse)
async def create_mood(
    mood_data: MoodCreate,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        # 1. Call Gemini AI first to generate the personalized quote + advice
        ai_result = await generate_mood_insight(
            mood=mood_data.mood,
            reflection=mood_data.reflection or ""
        )

        # 2. Save the mood + AI output to DB together
        new_mood = Mood(
            user_id=current_user.id,
            mood=mood_data.mood,
            reflection=mood_data.reflection,
            ai_quote=ai_result.get("quote"),
            ai_advice=ai_result.get("advice"),
            partner_name=current_user.partner_name,
        )
        db.add(new_mood)
        db.commit()
        db.refresh(new_mood)

        # 3. Schedule background notifications (Trigger 4 & Trigger 7)
        background_tasks.add_task(
            _trigger_mood_notifications,
            current_user.id,
            current_user.partner_id,
            new_mood.id,
            db
        )

        # 4. Return mood with persisted AI insight
        return {
            "id": new_mood.id,
            "mood": new_mood.mood,
            "reflection": new_mood.reflection,
            "created_at": new_mood.created_at,
            "ai_quote": new_mood.ai_quote,
            "ai_advice": new_mood.ai_advice,
            "partner_name": new_mood.partner_name,
        }
    except Exception as e:
        db.rollback()
        logger.error(f"Database error in create_mood: {e}")
        raise HTTPException(status_code=500, detail="An internal error occurred. Please try again.")

@router.get("/", response_model=List[MoodResponse])
async def get_my_moods(
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    moods = db.query(Mood).filter(Mood.user_id == current_user.id).order_by(Mood.created_at.desc()).offset(skip).limit(limit).all()
    # Return historical moods with persisted AI fields from DB
    return [
        {
            "id": m.id,
            "mood": m.mood,
            "reflection": m.reflection,
            "created_at": m.created_at,
            "ai_quote": m.ai_quote,
            "ai_advice": m.ai_advice,
            "partner_name": m.partner_name,
        }
        for m in moods
    ]

@router.get("/history")
async def get_mood_history(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    moods = db.query(Mood).filter(Mood.user_id == current_user.id).order_by(Mood.created_at.desc()).all()
    
    emoji_map = {
        "longing": "❤️",
        "peaceful": "😌",
        "reflective": "💭",
        "growing": "🌱"
    }
    
    history = []
    for m in moods:
        if not m.created_at:
            continue
        date_str = m.created_at.strftime("%Y-%m-%d")
        emoji = emoji_map.get(m.mood.lower(), "💭")
        
        history.append({
            "date": date_str,
            "mood": m.mood.lower(),
            "emoji": emoji,
            "note": m.reflection,
            "partner_name": m.partner_name
        })
        
    return history
