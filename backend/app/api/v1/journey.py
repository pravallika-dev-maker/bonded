from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from datetime import date, datetime
from typing import List, Optional
from ...database import get_db
from sqlalchemy import func
from ..deps import get_current_user, get_active_relationship
from ...models.user import User
from ...models.separation import Separation
from ...models.reflection_session import ReflectionSession
from ...models.reflection_answer import ReflectionAnswer
from ...models.reflection_question import ReflectionQuestion
from ...models.letter import Letter
from ...models.mood import Mood
from ...services.ai_service import generate_journey_insights
from ...services.notification_service import create_notification_and_push
import json

router = APIRouter(prefix="/journey", tags=["Journey"])

def get_love_word(score: int) -> dict:
    if score <= 50:
        return {"loveWord": "Seedling", "emoji": "🌱", "message": "Just beginning — every single step counts."}
    elif score <= 150:
        return {"loveWord": "Blooming", "emoji": "🌸", "message": "You are growing beautifully. Keep showing up."}
    elif score <= 300:
        return {"loveWord": "Passionate", "emoji": "🔥", "message": "Deep investment and beautiful consistency."}
    elif score <= 500:
        return {"loveWord": "Devoted", "emoji": "💎", "message": "Rare level of commitment and beautiful vulnerability."}
    else:
        return {"loveWord": "Soulbound", "emoji": "👑", "message": "A truly profound, healed, and deep connection."}

def calculate_user_score(db: Session, user: User, active_rel, active_sep=None) -> int:
    score = 0
    if not active_sep:
        return 0

    # 1. Action: Completed Reflections (+5 each)
    reflections_count = db.query(ReflectionSession).filter(
        ReflectionSession.user_id == user.id,
        ReflectionSession.separation_id == active_sep.id,
        ReflectionSession.is_completed == True
    ).count()
    score += reflections_count * 5

    # 2. Action: Shared Reflections (+10 bonus each day completed by both)
    if user.partner_id:
        shared_days_count = db.query(ReflectionSession.day_number).filter(
            ReflectionSession.user_id == user.id,
            ReflectionSession.separation_id == active_sep.id,
            ReflectionSession.is_completed == True
        ).intersect(
            db.query(ReflectionSession.day_number).filter(
                ReflectionSession.user_id == user.partner_id,
                ReflectionSession.separation_id == active_sep.id,
                ReflectionSession.is_completed == True
            )
        ).count()
        score += shared_days_count * 10

    # 3. Action: Write a Letter (+5 each)
    letters_query = db.query(Letter).filter(
        Letter.author_id == user.id,
        Letter.created_at >= active_sep.created_at
    )
    if active_rel:
        letters_query = letters_query.filter(Letter.relationship_id == active_rel.id)
    score += letters_query.count() * 5

    # 4. Action: Letter AI love score >= 80 (+15 each)
    high_score_letters_query = db.query(Letter).filter(
        Letter.author_id == user.id,
        Letter.ai_love_score >= 80,
        Letter.created_at >= active_sep.created_at
    )
    if active_rel:
        high_score_letters_query = high_score_letters_query.filter(Letter.relationship_id == active_rel.id)
    score += high_score_letters_query.count() * 15

    # 5. Action: Log a mood (+3 each)
    moods_count = db.query(Mood).filter(
        Mood.user_id == user.id,
        Mood.created_at >= active_sep.created_at
    ).count()
    score += moods_count * 3

    # 6. Action: Log a positive mood (+5 each)
    positive_moods_count = db.query(Mood).filter(
        Mood.user_id == user.id,
        Mood.created_at >= active_sep.created_at,
        Mood.mood.in_(["peaceful", "hopeful", "grateful", "loving", "joyful", "happy"])
    ).count()
    score += positive_moods_count * 5

    # 7. Action: Complete a full separation (+20)
    if active_sep.status == "completed":
        score += 20

    # 8. Emotion Bonus: tone & emotion analysis (Filtered to current separation)
    answers = db.query(ReflectionAnswer).join(
        ReflectionSession, ReflectionAnswer.session_id == ReflectionSession.id
    ).filter(
        ReflectionAnswer.user_id == user.id,
        ReflectionSession.separation_id == active_sep.id
    ).all()
    for ans in answers:
        # Tone bonus
        tone = (ans.ai_tone or "").lower()
        if tone in ["warm", "hopeful"]:
            score += 10
        elif tone == "reflective":
            score += 7
        elif tone in ["sad", "fearful"]:
            score += 4
        elif tone == "neutral":
            score += 3
        elif tone in ["angry", "bitter"]:
            score += 0
            
        # Emotion bonus
        emotion = (ans.ai_emotion_detected or "").lower()
        if emotion in ["love", "grateful", "longing"]:
            score += 8

    return score

@router.get("/score")
async def get_journey_score(
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    active_rel = Depends(get_active_relationship)
):
    """
    Calculates the dynamic Relationship Health Score for the couple.
    loveWord is derived from BOTH partners' combined score — it is a couple concept.
    Also returns each partner's individual score for display.
    """
    if not active_rel:
        return {
            "loveWord": "Seedling",
            "emoji": "🌱",
            "message": "Start a connection to begin your journey.",
            "coupleScore": 0,
            "statusChips": ["Waiting for partner"],
            "myScore": 0,
            "partnerScore": 0,
            "partnerName": None,
            "checkInsProgress": 0.0,
            "opennessProgress": 0.0,
            "presenceProgress": 0.0,
        }

    active_sep = db.query(Separation).filter(
        (Separation.creator_id == current_user.id) | (Separation.partner_id == current_user.id),
        Separation.status == "active"
    ).order_by(Separation.created_at.desc()).first()

    if not active_sep:
        return {
            "loveWord": "Seedling",
            "emoji": "🌱",
            "message": "Start a separation space to track your bond.",
            "coupleScore": 0,
            "statusChips": ["Quietly growing"],
            "myScore": 0,
            "partnerScore": 0,
            "partnerName": current_user.partner_name,
            "checkInsProgress": 0.0,
            "opennessProgress": 0.0,
            "presenceProgress": 0.0,
        }

    score = calculate_user_score(db, current_user, active_rel, active_sep)

    old_couple_score = current_user.relationship_score or 0

    # Update cached relationship_score in db silently
    current_user.relationship_score = score
    db.commit()

    # ── Partner score ─────────────────────────────────────────────────────────
    # loveWord is a COUPLE concept — derived from both partners' combined score.
    partner_score = 0
    partner_name = None
    old_partner_score = 0
    partner_fcm_token = None
    if current_user.partner_id:
        partner = db.query(User).filter(User.id == current_user.partner_id).first()
        if partner:
            partner_name = partner.user_name or current_user.partner_name
            old_partner_score = partner.relationship_score or 0
            partner_score = calculate_user_score(db, partner, active_rel, active_sep)
            partner.relationship_score = partner_score
            partner_fcm_token = partner.fcm_token
            db.commit()

    old_total = old_couple_score + old_partner_score
    couple_score = score + partner_score
    
    # ── Trigger 9: Score milestone ────────────────────────────────────────────
    milestones = [50, 150, 300, 500, 1000]
    crossed = None
    for m in milestones:
        if old_total < m <= couple_score:
            crossed = m
            
    # Removed score milestone notification as requested
    
    love_info = get_love_word(couple_score)

    # Calculate sub-indicators (percentage 0.0 to 1.0)
    # Check-ins progress: based on reflection completions (out of 10 completions max for scale)
    reflections_completed = db.query(ReflectionSession).filter(
        ReflectionSession.user_id == current_user.id,
        ReflectionSession.separation_id == active_sep.id,
        ReflectionSession.is_completed == True
    ).count()
    checkins_progress = min(1.0, reflections_completed / 10.0)

    # Openness progress: based on emotional warmth (ratio of warm/hopeful answers)
    total_answers = db.query(ReflectionAnswer).join(
        ReflectionSession, ReflectionAnswer.session_id == ReflectionSession.id
    ).filter(
        ReflectionAnswer.user_id == current_user.id,
        ReflectionSession.separation_id == active_sep.id
    ).count()
    warm_answers = db.query(ReflectionAnswer).join(
        ReflectionSession, ReflectionAnswer.session_id == ReflectionSession.id
    ).filter(
        ReflectionAnswer.user_id == current_user.id,
        ReflectionSession.separation_id == active_sep.id,
        ReflectionAnswer.ai_tone.in_(["warm", "hopeful"])
    ).count()
    openness_progress = (warm_answers / total_answers) if total_answers > 0 else 0.4

    # Presence progress: based on mood logging frequency (out of 15 logs max)
    moods_logged = db.query(Mood).filter(
        Mood.user_id == current_user.id,
        Mood.created_at >= active_sep.created_at
    ).count()
    presence_progress = min(1.0, moods_logged / 15.0)

    return {
        # Couple-level — loveWord comes from BOTH partners combined
        "loveWord": love_info["loveWord"],
        "emoji": love_info["emoji"],
        "message": love_info["message"],
        "coupleScore": couple_score,
        "statusChips": [love_info["loveWord"], "Quietly growing"],

        # Individual scores (for display breakdown if needed)
        "myScore": score,
        "partnerScore": partner_score,
        "partnerName": partner_name,

        # Sub-indicators (your personal progress bars)
        "checkInsProgress": round(checkins_progress, 2),
        "opennessProgress": round(openness_progress, 2),
        "presenceProgress": round(presence_progress, 2),
    }

@router.get("/insights")
async def get_journey_insights(
    background_tasks: BackgroundTasks,
    separation_id: Optional[int] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    active_rel = Depends(get_active_relationship)
):
    """
    Reveals mature AI-generated insights at the end of the separation day.
    Checks if expected_end_date of the active separation is reached, completed,
    or if both partners completed all reflection days.
    """

    # 1. Fetch separation (specific ID or active or latest completed)
    if separation_id:
        sep = db.query(Separation).filter(
            Separation.id == separation_id,
            (Separation.creator_id == current_user.id) | (Separation.partner_id == current_user.id)
        ).first()
    else:
        # Fetch active separation first
        sep = db.query(Separation).filter(
            (Separation.creator_id == current_user.id) | (Separation.partner_id == current_user.id),
            Separation.status == "active"
        ).order_by(Separation.created_at.desc()).first()

        if not sep:
            # Fallback: most recent completed separation for this user
            sep_query = db.query(Separation).filter(
                (Separation.creator_id == current_user.id) | (Separation.partner_id == current_user.id),
                Separation.status == "completed"
            ).order_by(Separation.ended_at.desc())
            if active_rel:
                sep_query = sep_query.filter(Separation.relationship_id == active_rel.id)
            sep = sep_query.first()

    if not sep:
        return {
            "isUnlocked": False,
            "daysRemaining": 99,
            "message": "Start a Separation space to unlock your insights vault.",
            "insights": None
        }

    # 2. Retrieve partner info — prefer current_user.partner_id, but fall back
    # to whoever the *other person* in the separation record is. This ensures
    # insights unlock even if the live partner relationship was dissolved.
    partner_user_id = current_user.partner_id
    if not partner_user_id:
        # Derive partner from the separation record itself
        if sep.creator_id == current_user.id:
            partner_user_id = sep.partner_id
        else:
            partner_user_id = sep.creator_id

    if not partner_user_id:
        return {
            "isUnlocked": False,
            "daysRemaining": 99,
            "message": "Insights are unavailable because you are no longer connected.",
            "insights": None
        }
    partner = db.query(User).filter(User.id == partner_user_id).first()
    partner_name = partner.user_name if (partner and partner.user_name) else "Partner"

    # Count shared completed reflection days for this specific separation
    shared_days_query = db.query(ReflectionSession.day_number).filter(
        ReflectionSession.user_id == current_user.id,
        ReflectionSession.separation_id == sep.id,
        ReflectionSession.is_completed == True
    ).intersect(
        db.query(ReflectionSession.day_number).filter(
            ReflectionSession.user_id == partner_user_id,
            ReflectionSession.separation_id == sep.id,
            ReflectionSession.is_completed == True
        )
    )
    shared_days = shared_days_query.count()

    # Calculate total expected reflection days
    if sep.expected_end_date and sep.start_date:
        expected_days = (sep.expected_end_date - sep.start_date).days
    else:
        duration_label = (sep.duration_label or "").lower()
        expected_days = 7  # default
        import re
        match = re.search(r'(\d+)', duration_label)
        if match:
            expected_days = int(match.group(1))
        elif "2" in duration_label or "two" in duration_label:
            expected_days = 14
        elif "month" in duration_label or "30" in duration_label:
            expected_days = 30

    # Auto-unlock early if both partners completed all required reflection days
    completed_all_reflections = (shared_days >= expected_days)

    # Check if locked or unlocked
    days_elapsed = (date.today() - sep.start_date).days + 1
    days_remaining = expected_days - days_elapsed
    if days_remaining < 0:
        days_remaining = 0
        
    is_unlocked = (days_remaining <= 0) or (sep.status == "completed") or completed_all_reflections

    if not is_unlocked:
        # If locked, return the status so the vault remains visual & locked on frontend
        return {
            "isUnlocked": False,
            "daysRemaining": max(0, days_remaining),
            "message": f"Your insights vault unlocks on the final day of separation ({days_remaining} days left).",
            "insights": None
        }

    # 4. Gather Journey Data to feed Gemini
    # User reflections
    user_reflections = db.query(ReflectionAnswer, ReflectionQuestion).join(
        ReflectionQuestion, ReflectionAnswer.question_id == ReflectionQuestion.id
    ).join(
        ReflectionSession, ReflectionAnswer.session_id == ReflectionSession.id
    ).filter(
        ReflectionAnswer.user_id == current_user.id,
        ReflectionSession.separation_id == sep.id
    ).all()
    
    user_ref_data = [
        {
            "question": q.question_text,
            "answer": ans.text_answer,
            "emotion": ans.ai_emotion_detected,
            "tone": ans.ai_tone
        } for ans, q in user_reflections
    ]

    # Partner reflections
    partner_reflections = db.query(ReflectionAnswer, ReflectionQuestion).join(
        ReflectionQuestion, ReflectionAnswer.question_id == ReflectionQuestion.id
    ).join(
        ReflectionSession, ReflectionAnswer.session_id == ReflectionSession.id
    ).filter(
        ReflectionAnswer.user_id == partner_user_id,
        ReflectionSession.separation_id == sep.id
    ).all()
    
    partner_ref_data = [
        {
            "question": q.question_text,
            "answer": ans.text_answer,
            "emotion": ans.ai_emotion_detected,
            "tone": ans.ai_tone
        } for ans, q in partner_reflections
    ]

    # Moods during this period
    user_moods = [m.mood for m in db.query(Mood).filter(
        Mood.user_id == current_user.id, 
        func.date(Mood.created_at) >= sep.start_date
    ).order_by(Mood.created_at.desc()).limit(10).all()]
    partner_moods = [m.mood for m in db.query(Mood).filter(
        Mood.user_id == partner_user_id,
        func.date(Mood.created_at) >= sep.start_date
    ).order_by(Mood.created_at.desc()).limit(10).all()]

    # Total counts
    user_total_days = db.query(ReflectionSession).filter(
        ReflectionSession.user_id == current_user.id, 
        ReflectionSession.separation_id == sep.id,
        ReflectionSession.is_completed == True
    ).count()
    partner_total_days = db.query(ReflectionSession).filter(
        ReflectionSession.user_id == partner_user_id, 
        ReflectionSession.separation_id == sep.id,
        ReflectionSession.is_completed == True
    ).count()
    
    # shared_days is already calculated above in line 284, no need to recalculate, but we'll assign it here for completeness
    
    user_letters_query = db.query(Letter).filter(
        Letter.author_id == current_user.id,
        func.date(Letter.created_at) >= sep.start_date
    )
    partner_letters_query = db.query(Letter).filter(
        Letter.author_id == partner_user_id,
        func.date(Letter.created_at) >= sep.start_date
    )
    if active_rel:
        user_letters_query = user_letters_query.filter(Letter.relationship_id == active_rel.id)
        partner_letters_query = partner_letters_query.filter(Letter.relationship_id == active_rel.id)
    
    user_letters = user_letters_query.count()
    partner_letters = partner_letters_query.count()

    bundle_data = {
        "partner_a_reflections": user_ref_data,
        "partner_b_reflections": partner_ref_data,
        "partner_a_moods": user_moods,
        "partner_b_moods": partner_moods,
        "shared_days": shared_days,
        "partner_a_total_days": user_total_days,
        "partner_b_total_days": partner_total_days,
        "partner_a_letters": user_letters,
        "partner_b_letters": partner_letters
    }

    # 5. Ask Gemini to generate mature, loving insights (only if not already generated)
    try:
        all_insights = json.loads(sep.closing_insight) if sep.closing_insight else {}
    except Exception:
        all_insights = {}

    user_id_str = str(current_user.id)

    # Legacy format fallback
    if all_insights and "bondScore" in all_insights:
        all_insights = {}

    if user_id_str not in all_insights:
        insights = await generate_journey_insights(current_user.user_name or "You", partner_name, bundle_data)
        
        all_insights[user_id_str] = insights
        sep.closing_insight = json.dumps(all_insights)
        db.commit()
    else:
        insights = all_insights[user_id_str]

    return {
        "isUnlocked": True,
        "daysRemaining": 0,
        "message": "Your insights are successfully unlocked.",
        "insights": insights
    }
