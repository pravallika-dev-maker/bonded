import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import date, datetime, timezone, timedelta

from ...database import get_db
from ..deps import get_current_user
from ...models.user import User
from ...models.separation import Separation
from ...models.relationship import Relationship
from ...models.reflection_question import ReflectionQuestion
from ...models.reflection_session import ReflectionSession
from ...models.reflection_answer import ReflectionAnswer
from ...schemas.reflection import (
    TodayQuestionResponse, QuestionOut,
    AnswerRequest, AnswerResponse, AIReaction,
    TodayStatusResponse,
)
from ...services.ai_service import analyze_answer

router = APIRouter(prefix="/reflections", tags=["Reflections"])
logger = logging.getLogger("bonded.reflections")


# ── Helper: get active separation or raise 404 ───────────────────────────────

def _get_active_separation(user: User, db: Session) -> Separation:
    """
    Resolves the active separation by checking if the user is the creator or partner.
    Supports both connected relationships and solo separations.
    """
    sep = db.query(Separation).filter(
        (Separation.creator_id == user.id) | (Separation.partner_id == user.id),
        Separation.status == "active"
    ).order_by(Separation.created_at.desc()).first()

    if not sep:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No active separation found. Start a separation first."
        )
    return sep


# ── Helper: compute today's logical date ─────────────────────────────────────

def _get_logical_date(dt: datetime = None) -> date:
    """
    Returns the logical date for a given datetime in IST (UTC+5:30).
    This ensures that the 'day' rolls over exactly at 12:00 AM IST consistently
    across both day calculations and today's status checks.
    """
    if dt is None:
        dt = datetime.now(timezone.utc)
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    ist_offset = timedelta(hours=5, minutes=30)
    return (dt + ist_offset).date()

# ── Helper: compute today's day_number from separation start ─────────────────

def _day_number(user_id: int, sep: Separation, db: Session) -> int:
    today_logical = _get_logical_date()
    
    # 1. Unique dates with a mood BEFORE today
    from ...models.mood import Mood
    moods = db.query(Mood.created_at).filter(
        Mood.user_id == user_id,
        Mood.created_at >= datetime.combine(sep.start_date, datetime.min.time()).replace(tzinfo=timezone.utc)
    ).all()
    mood_dates_before_today = {_get_logical_date(m[0]) for m in moods if m[0] and _get_logical_date(m[0]) < today_logical}
    
    # 2. Unique dates with a completed reflection BEFORE today
    from ...models.reflection_session import ReflectionSession
    sessions = db.query(ReflectionSession.completed_at).filter(
        ReflectionSession.user_id == user_id,
        ReflectionSession.separation_id == sep.id,
        ReflectionSession.is_completed == True,
    ).all()
    reflection_dates_before_today = {_get_logical_date(s[0]) for s in sessions if s[0] and _get_logical_date(s[0]) < today_logical}
    
    completed_steps = min(len(mood_dates_before_today), len(reflection_dates_before_today))
    
    journey_day = completed_steps + 1
    
    # Cap days active between 1 and 55 (max questions)
    return max(1, min(journey_day, 55))


# ── Helper: get or create today's session ────────────────────────────────────

def _get_or_create_session(user_id: int, sep_id: int, day: int, db: Session) -> ReflectionSession:
    session = db.query(ReflectionSession).filter(
        ReflectionSession.user_id == user_id,
        ReflectionSession.separation_id == sep_id,
        ReflectionSession.day_number == day,
    ).first()
    if not session:
        session = ReflectionSession(
            user_id=user_id,
            separation_id=sep_id,
            day_number=day,
        )
        db.add(session)
        db.commit()
        db.refresh(session)
    return session


# ────────────────────────────────────────────────────────────────────────────
# ENDPOINTS
# ────────────────────────────────────────────────────────────────────────────


@router.get("/questions/today", response_model=TodayQuestionResponse)
async def get_today_question(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Returns today's reflection question and creates (or returns existing)
    session for the current user.
    """
    sep = _get_active_separation(current_user, db)
    day = _day_number(current_user.id, sep, db)

    question = db.query(ReflectionQuestion).filter(
        ReflectionQuestion.day_number == day,
        ReflectionQuestion.is_active == True,
    ).first()

    if not question:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No question found for day {day}. Make sure the database is seeded."
        )

    session = _get_or_create_session(current_user.id, sep.id, day, db)

    # Fetch category name for context
    category_name = None
    if question.category_id:
        from ...models.question_category import QuestionCategory
        cat = db.query(QuestionCategory).filter(
            QuestionCategory.id == question.category_id
        ).first()
        category_name = cat.name if cat else None

    is_missed_day = False

    return TodayQuestionResponse(
        session_id=session.id,
        day_number=day,
        is_completed=session.is_completed,
        is_missed_day=is_missed_day,
        question=QuestionOut(
            id=question.id,
            day_number=question.day_number,
            question_type=question.question_type,
            question_text=question.question_text,
            scenario_prefix=question.scenario_prefix,
            hint_text=question.hint_text,
            category_name=category_name,
        ),
    )


@router.post("/answer", response_model=AnswerResponse)
async def submit_answer(
    request: AnswerRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Saves the user's answer, calls Gemini AI to analyze it, marks today's
    reflection as completed, and returns the AI reaction.
    Since there is one question per day, answering automatically completes the session.
    """
    # Validate session belongs to this user
    session = db.query(ReflectionSession).filter(
        ReflectionSession.id == request.session_id,
        ReflectionSession.user_id == current_user.id,
    ).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    if session.is_completed:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Reflection already submitted for this day."
        )

    # Check if answer already exists for this question in this session
    existing = db.query(ReflectionAnswer).filter(
        ReflectionAnswer.session_id == session.id,
        ReflectionAnswer.question_id == request.question_id,
    ).first()
    if existing:
        raise HTTPException(
            status_code=400,
            detail="You have already submitted an answer for this reflection question."
        )

    # Fetch question text for AI prompt
    question = db.query(ReflectionQuestion).filter(
        ReflectionQuestion.id == request.question_id
    ).first()
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")

    # ── Call Gemini AI ──────────────────────────────────────────────────────
    ai_result = await analyze_answer(
        question_text=question.question_text,
        user_answer=request.text_answer,
    )

    # ── Persist answer + AI result ──────────────────────────────────────────
    answer = ReflectionAnswer(
        session_id=session.id,
        user_id=current_user.id,
        question_id=request.question_id,
        text_answer=request.text_answer,
        ai_emotion_detected=ai_result.get("emotion_detected", "neutral"),
        ai_tone=ai_result.get("tone", "neutral"),
        ai_reaction_text=ai_result.get("reaction_text", "Thank you for sharing."),
        ai_processed=True,
    )
    db.add(answer)
    db.commit()
    db.refresh(answer)

    # ── Mark session as completed (one question = one day done) ─────────────
    session.is_completed = True
    session.completed_at = datetime.now(timezone.utc)
    db.commit()
    logger.info(f"User {current_user.id} completed reflection session {session.id} for day {session.day_number}")

    return AnswerResponse(
        answer_id=answer.id,
        ai_reaction=AIReaction(
            emotion_detected=answer.ai_emotion_detected,
            tone=answer.ai_tone,
            reaction_text=answer.ai_reaction_text,
        ),
        is_completed=True,
    )


@router.get("/today/status", response_model=TodayStatusResponse)
async def get_today_status(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Returns whether the user and their partner have completed today's reflection,
    plus total completed day counts for both. Used by the home screen.
    """
    sep = _get_active_separation(current_user, db)
    day = _day_number(current_user.id, sep, db)

    current_logical_date = _get_logical_date()
    
    # Today's completion status for current user
    latest_user_session = db.query(ReflectionSession).filter(
        ReflectionSession.user_id == current_user.id,
        ReflectionSession.separation_id == sep.id,
        ReflectionSession.is_completed == True,
    ).order_by(ReflectionSession.completed_at.desc()).first()
    
    user_completed = False
    if latest_user_session and latest_user_session.completed_at:
        completed_logical_date = _get_logical_date(latest_user_session.completed_at)
        if completed_logical_date == current_logical_date:
            user_completed = True

    # Total completed days for current user in this separation
    # Calculate based on day_number to avoid exposing time-travel test records
    user_total_completed = day if user_completed else max(0, day - 1)

    # Partner status (partner_id on the separation row is the other user's id)
    partner_completed = False
    partner_total_completed = 0
    shared_days_completed = 0

    partner_user_id = sep.partner_id if sep.creator_id == current_user.id else sep.creator_id
    if partner_user_id:
        latest_partner_session = db.query(ReflectionSession).filter(
            ReflectionSession.user_id == partner_user_id,
            ReflectionSession.separation_id == sep.id,
            ReflectionSession.is_completed == True,
        ).order_by(ReflectionSession.completed_at.desc()).first()
        
        if latest_partner_session and latest_partner_session.completed_at:
            utc_dt = latest_partner_session.completed_at.replace(tzinfo=timezone.utc)
            completed_ist_date = (utc_dt + ist_offset).date()
            if completed_ist_date == current_ist_date:
                partner_completed = True

        # Partner total completed days based on their progress to hide test records
        partner_day = _day_number(partner_user_id, sep, db)
        partner_total_completed = partner_day if partner_completed else max(0, partner_day - 1)

        # Days where BOTH partners completed their reflection in this separation
        user_completed_days = db.query(ReflectionSession.day_number).filter(
            ReflectionSession.user_id == current_user.id,
            ReflectionSession.separation_id == sep.id,
            ReflectionSession.is_completed == True,
        )
        partner_completed_days = db.query(ReflectionSession.day_number).filter(
            ReflectionSession.user_id == partner_user_id,
            ReflectionSession.separation_id == sep.id,
            ReflectionSession.is_completed == True,
        )
        shared_days_completed = user_completed_days.intersect(partner_completed_days).count()

    return TodayStatusResponse(
        day_number=day,
        user_completed=user_completed,
        partner_completed=partner_completed,
        user_total_completed=user_total_completed,
        partner_total_completed=partner_total_completed,
        shared_days_completed=shared_days_completed,
    )
