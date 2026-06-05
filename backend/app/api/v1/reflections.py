from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from datetime import date, datetime, timezone
from typing import Optional

from ...database import get_db
from ..deps import get_current_user
from ...models.user import User
from ...models.separation import Separation
from ...models.reflection_question import ReflectionQuestion
from ...models.reflection_session import ReflectionSession
from ...models.reflection_answer import ReflectionAnswer
from ...models.reflection_comparison import ReflectionComparison
from ...models.notification import Notification
from ...schemas.reflection import (
    TodayQuestionResponse, QuestionOut,
    AnswerRequest, AnswerResponse, AIReaction,
    SubmitRequest, SubmitResponse,
    TodayStatusResponse, ComparisonResponse,
)
from ...services.ai_service import analyze_answer, generate_comparison_suggestions

router = APIRouter(prefix="/reflections", tags=["Reflections"])


# ── Helper: get active separation or raise 404 ───────────────────────────────

def _get_active_separation(user: User, db: Session) -> Separation:
    sep = db.query(Separation).filter(
        (Separation.creator_id == user.id) | (Separation.partner_id == user.id),
        Separation.status == "active"
    ).first()
    if not sep:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No active separation found. Start a separation first."
        )
    return sep


# ── Helper: compute today's day_number from separation start ─────────────────

def _day_number(sep: Separation) -> int:
    elapsed = (date.today() - sep.start_date).days
    day = max(1, elapsed + 1)  # Ensure day is at least 1, even with timezone shifts
    return min(day, 55)        # Cap at 55


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


# ── Helper: notify a user ─────────────────────────────────────────────────────

def _notify(db: Session, recipient_id: int, notif_type: str, title: str, body: str):
    notif = Notification(
        recipient_id=recipient_id,
        notification_type=notif_type,
        title=title,
        body=body,
    )
    db.add(notif)
    db.commit()


# ── Background task: generate and store comparison ───────────────────────────

async def _generate_comparison(
    sep_id: int,
    day: int,
    session_a_id: int,
    session_b_id: int,
    user_a_id: int,
    user_b_id: Optional[int],
    db: Session,
):
    """Called in background after both partners complete. Generates AI suggestions."""
    try:
        # Fetch all answers + questions for both sessions
        answers_a = db.query(ReflectionAnswer).filter(
            ReflectionAnswer.session_id == session_a_id
        ).all()
        answers_b = db.query(ReflectionAnswer).filter(
            ReflectionAnswer.session_id == session_b_id
        ).all()

        # Build summary for AI
        summary = []
        for ans_a in answers_a:
            question = db.query(ReflectionQuestion).filter(
                ReflectionQuestion.id == ans_a.question_id
            ).first()
            ans_b = next(
                (a for a in answers_b if a.question_id == ans_a.question_id), None
            )
            if question and ans_b:
                summary.append({
                    "question": question.question_text,
                    "partnerA": ans_a.text_answer or "",
                    "partnerB": ans_b.text_answer or "",
                })

        suggestions = await generate_comparison_suggestions(summary)

        # Upsert comparison record
        comparison = db.query(ReflectionComparison).filter(
            ReflectionComparison.separation_id == sep_id,
            ReflectionComparison.day_number == day,
        ).first()

        if comparison:
            comparison.suggestions = suggestions
            comparison.generated_at = datetime.now(timezone.utc)
        else:
            comparison = ReflectionComparison(
                separation_id=sep_id,
                day_number=day,
                user_a_session_id=session_a_id,
                user_b_session_id=session_b_id,
                suggestions=suggestions,
            )
            db.add(comparison)
        db.commit()

        # Notify both users that comparison is ready
        for uid in [user_a_id, user_b_id]:
            if uid:
                _notify(
                    db, uid,
                    "comparison_ready",
                    "Your reflections are aligned ✨",
                    "Both of you completed today's reflection. See how your answers compare.",
                )
    except Exception as e:
        print(f"[COMPARISON ERROR] day={day} sep={sep_id}: {e}")


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
    day = _day_number(sep)

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

    return TodayQuestionResponse(
        session_id=session.id,
        day_number=day,
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
    Saves one answer, calls Gemini AI to analyze it, and returns the AI reaction.
    This is called once per question (currently one question per day).
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
            status_code=400,
            detail="This reflection day is already completed."
        )

    # Check if answer already exists for this question in this session
    existing = db.query(ReflectionAnswer).filter(
        ReflectionAnswer.session_id == session.id,
        ReflectionAnswer.question_id == request.question_id,
    ).first()
    if existing:
        # Return cached AI reaction (idempotent)
        return AnswerResponse(
            answer_id=existing.id,
            ai_reaction=AIReaction(
                emotion_detected=existing.ai_emotion_detected or "neutral",
                tone=existing.ai_tone or "neutral",
                reaction_text=existing.ai_reaction_text or "Thank you for sharing.",
            ),
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

    return AnswerResponse(
        answer_id=answer.id,
        ai_reaction=AIReaction(
            emotion_detected=answer.ai_emotion_detected,
            tone=answer.ai_tone,
            reaction_text=answer.ai_reaction_text,
        ),
    )


@router.post("/submit", response_model=SubmitResponse)
async def submit_day(
    request: SubmitRequest,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Marks today's session as complete. If partner also completed,
    triggers background AI comparison generation.
    """
    session = db.query(ReflectionSession).filter(
        ReflectionSession.id == request.session_id,
        ReflectionSession.user_id == current_user.id,
    ).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    if session.is_completed:
        # Already submitted — return current state idempotently
        sep = _get_active_separation(current_user, db)
        partner_done, partner_session = _check_partner_completed(
            current_user, sep, session.day_number, db
        )
        comparison_ready = _comparison_exists(sep.id, session.day_number, db)
        return SubmitResponse(
            message="Already submitted.",
            partner_also_completed=partner_done,
            comparison_ready=comparison_ready,
        )

    # Validate at least one answer exists before marking complete
    answer_count = db.query(ReflectionAnswer).filter(
        ReflectionAnswer.session_id == session.id
    ).count()
    if answer_count == 0:
        raise HTTPException(
            status_code=400,
            detail="Cannot submit without answering the reflection question first."
        )

    # Mark complete
    session.is_completed = True
    session.completed_at = datetime.now(timezone.utc)
    db.commit()

    # ── Check if partner also completed ─────────────────────────────────────
    sep = _get_active_separation(current_user, db)
    partner_done, partner_session = _check_partner_completed(
        current_user, sep, session.day_number, db
    )
    comparison_ready = _comparison_exists(sep.id, session.day_number, db)

    if partner_done and partner_session and not comparison_ready:
        # Both partners done → trigger background comparison
        background_tasks.add_task(
            _generate_comparison,
            sep.id,
            session.day_number,
            session.id,
            partner_session.id,
            current_user.id,
            current_user.partner_id,
            db,
        )
        # Notify partner that this user completed
        if current_user.partner_id:
            _notify(
                db,
                current_user.partner_id,
                "partner_checked_in",
                f"{current_user.user_name or 'Your partner'} completed today's reflection",
                "Their answer is waiting. Complete yours to see the comparison.",
            )

    return SubmitResponse(
        message="Reflection submitted successfully.",
        partner_also_completed=partner_done,
        comparison_ready=comparison_ready,
    )


@router.get("/today/status", response_model=TodayStatusResponse)
async def get_today_status(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Returns whether the user (and partner) have completed today's reflection.
    Used by MainDashboardScreen to show the reflection badge state.
    """
    sep = _get_active_separation(current_user, db)
    day = _day_number(sep)

    user_session = db.query(ReflectionSession).filter(
        ReflectionSession.user_id == current_user.id,
        ReflectionSession.separation_id == sep.id,
        ReflectionSession.day_number == day,
    ).first()
    user_completed = bool(user_session and user_session.is_completed)

    partner_done, _ = _check_partner_completed(current_user, sep, day, db)
    comparison_ready = _comparison_exists(sep.id, day, db)

    return TodayStatusResponse(
        day_number=day,
        user_completed=user_completed,
        partner_completed=partner_done,
        comparison_ready=comparison_ready,
    )


@router.get("/comparison/today", response_model=ComparisonResponse)
async def get_today_comparison(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Returns AI-generated suggestions after both partners complete the same day.
    """
    sep = _get_active_separation(current_user, db)
    day = _day_number(sep)

    comparison = db.query(ReflectionComparison).filter(
        ReflectionComparison.separation_id == sep.id,
        ReflectionComparison.day_number == day,
    ).first()

    partner_done, _ = _check_partner_completed(current_user, sep, day, db)

    if not comparison:
        return ComparisonResponse(
            day_number=day,
            suggestions=[],
            partner_completed=partner_done,
        )

    suggestions = comparison.suggestions or []
    if not isinstance(suggestions, list):
        suggestions = []

    return ComparisonResponse(
        day_number=day,
        suggestions=suggestions,
        partner_completed=partner_done,
    )


# ── Private helpers ──────────────────────────────────────────────────────────

def _check_partner_completed(
    user: User, sep: Separation, day: int, db: Session
):
    """Returns (partner_completed: bool, partner_session | None)."""
    if not user.partner_id:
        return False, None
    partner_session = db.query(ReflectionSession).filter(
        ReflectionSession.user_id == user.partner_id,
        ReflectionSession.separation_id == sep.id,
        ReflectionSession.day_number == day,
        ReflectionSession.is_completed == True,
    ).first()
    return bool(partner_session), partner_session


def _comparison_exists(sep_id: int, day: int, db: Session) -> bool:
    return db.query(ReflectionComparison).filter(
        ReflectionComparison.separation_id == sep_id,
        ReflectionComparison.day_number == day,
    ).first() is not None
