import logging
from datetime import date, timedelta
from sqlalchemy.orm import Session
from ..models.user_daily_affirmation import UserDailyAffirmation
from ..models.user_daily_insight import UserDailyInsight
from ..models.user import User
from .ai_service import generate_daily_affirmation, generate_daily_insight

logger = logging.getLogger("bonded.daily_content")

async def get_or_create_daily_affirmation(
    db: Session,
    current_user: User,
    in_separation: bool
) -> str:
    today = date.today()
    
    # 1. Check if we already have one for today
    existing = db.query(UserDailyAffirmation).filter(
        UserDailyAffirmation.user_id == current_user.id,
        UserDailyAffirmation.affirmation_date == today
    ).first()
    if existing:
        return existing.text
        
    # 2. Get recent affirmations to avoid duplicates
    seven_days_ago = today - timedelta(days=7)
    recent_affs = db.query(UserDailyAffirmation.text).filter(
        UserDailyAffirmation.user_id == current_user.id,
        UserDailyAffirmation.affirmation_date >= seven_days_ago
    ).all()
    recent_texts = [aff[0] for aff in recent_affs]
    
    # 3. Generate new affirmation
    try:
        new_text = await generate_daily_affirmation(
            user_name=current_user.user_name or "Friend",
            in_separation=in_separation,
            recent_affirmations=recent_texts
        )
        
        # 4. Save to DB
        new_aff = UserDailyAffirmation(
            user_id=current_user.id,
            affirmation_date=today,
            text=new_text
        )
        db.add(new_aff)
        db.commit()
        
        return new_text
    except Exception as e:
        logger.error(f"Error in get_or_create_daily_affirmation: {e}")
        db.rollback()
        return "Every quiet step you take toward understanding is a step toward deeper love."


async def get_or_create_daily_insight(
    db: Session,
    current_user: User,
    mood_history: list,
    reflection_history: list
) -> str:
    today = date.today()
    
    # 1. Check if we already have one for today
    existing = db.query(UserDailyInsight).filter(
        UserDailyInsight.user_id == current_user.id,
        UserDailyInsight.insight_date == today
    ).first()
    if existing:
        return existing.text
        
    # 2. Get recent insights to avoid duplicates
    seven_days_ago = today - timedelta(days=7)
    recent_ins = db.query(UserDailyInsight.text).filter(
        UserDailyInsight.user_id == current_user.id,
        UserDailyInsight.insight_date >= seven_days_ago
    ).all()
    recent_texts = [ins[0] for ins in recent_ins]
    
    # 3. Generate new insight
    try:
        new_text = await generate_daily_insight(
            user_name=current_user.user_name or "Friend",
            mood_history=mood_history,
            reflection_history=reflection_history,
            recent_insights=recent_texts
        )
        
        # 4. Save to DB
        new_insight = UserDailyInsight(
            user_id=current_user.id,
            insight_date=today,
            text=new_text
        )
        db.add(new_insight)
        db.commit()
        
        return new_text
    except Exception as e:
        logger.error(f"Error in get_or_create_daily_insight: {e}")
        db.rollback()
        return "Your emotional awareness continues to grow as you process your feelings openly."
