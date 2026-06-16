import logging
from datetime import date, datetime, timezone
from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session
from ...database import get_db
from ...schemas.daily_content import DailyAffirmationResponse, DailyInsightResponse, MarkInsightViewedResponse
from ...services.daily_content_service import get_or_create_daily_affirmation, get_or_create_daily_insight
from ...models.user_daily_insight import UserDailyInsight
from ..deps import get_current_user
from ...models.user import User
from ...models.separation import Separation
from ...models.relationship import Relationship
from ...models.mood import Mood
from ...models.reflection_answer import ReflectionAnswer
from ...models.reflection_question import ReflectionQuestion

router = APIRouter(prefix="/daily", tags=["Daily Content"])
logger = logging.getLogger("bonded.api.daily_content")

@router.get("/affirmation", response_model=DailyAffirmationResponse)
async def get_daily_affirmation(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        # Determine if there is an active separation
        active_rel = db.query(Relationship).filter(
            (Relationship.user1_id == current_user.id) | (Relationship.user2_id == current_user.id),
            Relationship.status == "active"
        ).first()

        in_separation = False
        if active_rel:
            active_sep = db.query(Separation).filter(
                Separation.relationship_id == active_rel.id,
                Separation.status == "active"
            ).order_by(Separation.created_at.desc()).first()
            in_separation = active_sep is not None

        affirmation_text = await get_or_create_daily_affirmation(
            db=db,
            current_user=current_user,
            in_separation=in_separation
        )

        return DailyAffirmationResponse(
            date=date.today(),
            affirmation=affirmation_text
        )

    except Exception as e:
        logger.error(f"Error fetching daily affirmation: {e}")
        raise HTTPException(status_code=500, detail="Could not fetch daily affirmation")


@router.get("/insight", response_model=DailyInsightResponse)
async def get_daily_insight(
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        # 1. (Removed partner check so solo users in active separations can unlock insights)

        # 2. Check Unlock Condition (Mood logged today based on user's timezone)
        tz_offset_str = request.headers.get("X-Timezone-Offset")
        now_utc = datetime.now(timezone.utc)
        
        try:
            if tz_offset_str:
                from datetime import timedelta
                offset_minutes = int(tz_offset_str)
                # Apply the offset to get the user's local time
                client_tz = timezone(timedelta(minutes=offset_minutes))
                now_client = now_utc.astimezone(client_tz)
                print(f"DEBUG - current server datetime: {datetime.now()}")
                print(f"DEBUG - current server date: {date.today()}")
                
                # Midnight in client's local time, converted to UTC bounds for the database
                today_start_client = datetime(now_client.year, now_client.month, now_client.day, tzinfo=client_tz)
                today_start = today_start_client.astimezone(timezone.utc)
            else:
                today_start = now_utc.replace(hour=0, minute=0, second=0, microsecond=0)
        except Exception as e:
            logger.error(f"Error parsing timezone offset: {e}")
            today_start = now_utc.replace(hour=0, minute=0, second=0, microsecond=0)
        
        mood_today = db.query(Mood).filter(
            Mood.user_id == current_user.id,
            Mood.created_at >= today_start
        ).first()
        
        if mood_today:
            print(f"DEBUG - mood created_at: {mood_today.created_at}")
            print(f"DEBUG - mood UTC date: {mood_today.created_at.astimezone(timezone.utc)}")
            print(f"DEBUG - unlock decision: UNLOCKED")
            print(f"DEBUG - is_locked value: False")
        else:
            print(f"DEBUG - unlock decision: LOCKED")
            print(f"DEBUG - is_locked value: True")

        if not mood_today:
            return DailyInsightResponse(
                date=date.today(),
                insight=None,
                is_locked=True,
                is_viewed=False,
                lock_reason="Complete today's mood check-in to unlock your daily insight."
            )

        # 2. Gather context
        recent_moods = db.query(Mood).filter(
            Mood.user_id == current_user.id
        ).order_by(Mood.created_at.desc()).limit(7).all()
        mood_list = [
            {"mood": m.mood, "reflection": m.reflection or ""}
            for m in recent_moods
        ]

        recent_answers = db.query(ReflectionAnswer, ReflectionQuestion).join(
            ReflectionQuestion, ReflectionAnswer.question_id == ReflectionQuestion.id
        ).filter(
            ReflectionAnswer.user_id == current_user.id
        ).order_by(ReflectionAnswer.id.desc()).limit(5).all()
        reflection_list = [
            {
                "question": q.question_text,
                "answer": ans.text_answer,
                "emotion": ans.ai_emotion_detected or "neutral",
            }
            for ans, q in recent_answers
        ]

        # 3. Generate or retrieve today's insight
        insight_text = await get_or_create_daily_insight(
            db=db,
            current_user=current_user,
            mood_history=mood_list,
            reflection_history=reflection_list
        )

        # 4. Check if already viewed
        today_insight_row = db.query(UserDailyInsight).filter(
            UserDailyInsight.user_id == current_user.id,
            UserDailyInsight.insight_date == date.today()
        ).first()
        is_viewed = bool(today_insight_row and today_insight_row.is_viewed)

        return DailyInsightResponse(
            date=date.today(),
            insight=insight_text,
            is_locked=False,
            lock_reason=None,
            is_viewed=is_viewed
        )

    except Exception as e:
        logger.error(f"Error fetching daily insight: {e}")
        raise HTTPException(status_code=500, detail="Could not fetch daily insight")


@router.post("/insight/mark-viewed", response_model=MarkInsightViewedResponse)
async def mark_insight_viewed(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Mark today's insight as viewed. Idempotent — safe to call multiple times."""
    try:
        today = date.today()
        row = db.query(UserDailyInsight).filter(
            UserDailyInsight.user_id == current_user.id,
            UserDailyInsight.insight_date == today
        ).first()

        if not row:
            return MarkInsightViewedResponse(success=False, message="No insight found for today.")

        if not row.is_viewed:
            row.is_viewed = True
            row.viewed_at = datetime.now(timezone.utc)
            db.commit()

        return MarkInsightViewedResponse(success=True, message="Insight marked as viewed.")

    except Exception as e:
        logger.error(f"Error marking insight as viewed: {e}")
        db.rollback()
        raise HTTPException(status_code=500, detail="Could not mark insight as viewed")
