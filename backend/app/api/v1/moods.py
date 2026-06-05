from fastapi import APIRouter, Depends, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List
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
            title="🔍 New self-discovery insight",
            body=insight_text,
            fcm_token=user.fcm_token
        )
        
        # 2. Trigger 7: Partner mood logged
        if partner_id:
            partner = db.query(User).filter(User.id == partner_id).first()
            if partner:
                partner_name = user.user_name or "Your partner"
                create_notification_and_push(
                    db=db,
                    recipient_id=partner_id,
                    notification_type="partner_mood",
                    title=f"🌤️ {partner_name} is feeling {new_mood.mood}",
                    body="They logged how they're feeling today.",
                    fcm_token=partner.fcm_token
                )
    except Exception as e:
        logger.error(f"Error in _trigger_mood_notifications: {e}")

@router.post("/", response_model=MoodResponse)
async def create_mood(
    mood_data: MoodCreate,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
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
    }

@router.get("/", response_model=List[MoodResponse])
async def get_my_moods(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    moods = db.query(Mood).filter(Mood.user_id == current_user.id).order_by(Mood.created_at.desc()).all()
    # Return historical moods with persisted AI fields from DB
    return [
        {
            "id": m.id,
            "mood": m.mood,
            "reflection": m.reflection,
            "created_at": m.created_at,
            "ai_quote": m.ai_quote,
            "ai_advice": m.ai_advice,
        }
        for m in moods
    ]
