from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from datetime import date, datetime
from typing import List, Optional
from ...database import get_db
from ..deps import get_current_user
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

def calculate_user_score(db: Session, user: User) -> int:
    score = 0

    # 1. Action: Completed Reflections (+5 each)
    reflections_count = db.query(ReflectionSession).filter(
        ReflectionSession.user_id == user.id,
        ReflectionSession.is_completed == True
    ).count()
    score += reflections_count * 5

    # 2. Action: Shared Reflections (+10 bonus each day completed by both)
    if user.partner_id:
        shared_days_count = db.query(ReflectionSession.day_number).filter(
            ReflectionSession.user_id == user.id,
            ReflectionSession.is_completed == True
        ).intersect(
            db.query(ReflectionSession.day_number).filter(
                ReflectionSession.user_id == user.partner_id,
                ReflectionSession.is_completed == True
            )
        ).count()
        score += shared_days_count * 10

    # 3. Action: Write a Letter (+5 each)
    letters_count = db.query(Letter).filter(Letter.author_id == user.id).count()
    score += letters_count * 5

    # 4. Action: Letter AI love score >= 80 (+15 each)
    high_score_letters = db.query(Letter).filter(
        Letter.author_id == user.id,
        Letter.ai_love_score >= 80
    ).count()
    score += high_score_letters * 15

    # 5. Action: Log a mood (+3 each)
    moods_count = db.query(Mood).filter(Mood.user_id == user.id).count()
    score += moods_count * 3

    # 6. Action: Log a positive mood (+5 each)
    # positive moods = peaceful, hopeful, grateful, loving, joyful, happy
    positive_moods_count = db.query(Mood).filter(
        Mood.user_id == user.id,
        Mood.mood.in_(["peaceful", "hopeful", "grateful", "loving", "joyful", "happy"])
    ).count()
    score += positive_moods_count * 5

    # 7. Action: Completed Separation (+20 each)
    completed_separations = db.query(Separation).filter(
        (Separation.creator_id == user.id) | (Separation.partner_id == user.id),
        Separation.status == "completed"
    ).count()
    score += completed_separations * 20

    # 8. Emotion Bonus: tone & emotion analysis
    answers = db.query(ReflectionAnswer).filter(ReflectionAnswer.user_id == user.id).all()
    for ans in answers:
        # Tone bonus
        tone = (ans.ai_tone or "").lower()
        if tone in ["warm", "hopeful"]:
            score += 10
        elif tone == "reflective":
            score += 7
        elif tone == "neutral":
            score += 3
        elif tone in ["sad", "fearful"]:
            score += 4
            
        # Emotion bonus
        emotion = (ans.ai_emotion_detected or "").lower()
        if emotion == "love":
            score += 10
        elif emotion == "longing":
            score += 8
        elif emotion == "grateful":
            score += 9
        elif emotion == "hopeful":
            score += 8
        elif emotion == "confused":
            score += 4
        elif emotion == "fearful":
            score += 3

    return score

@router.get("/score")
async def get_journey_score(
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Calculates the dynamic Relationship Health Score for the couple.
    loveWord is derived from BOTH partners' combined score — it is a couple concept.
    Also returns each partner's individual score for display.
    """
    score = calculate_user_score(db, current_user)

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
            partner_name = partner.user_name
            old_partner_score = partner.relationship_score or 0
            partner_score = calculate_user_score(db, partner)
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
            
    if crossed:
        title = "Love Milestone Unlocked! 🏆"
        body = f"You and your partner just reached {crossed} points! Keep growing together."
        
        background_tasks.add_task(
            create_notification_and_push,
            db,
            current_user.id,
            "score_milestone",
            title,
            body,
            current_user.fcm_token
        )
        
        if current_user.partner_id and partner_fcm_token:
            background_tasks.add_task(
                create_notification_and_push,
                db,
                current_user.partner_id,
                "score_milestone",
                title,
                body,
                partner_fcm_token
            )

    love_info = get_love_word(couple_score)

    # Calculate sub-indicators (percentage 0.0 to 1.0)
    # Check-ins progress: based on reflection completions (out of 10 completions max for scale)
    reflections_completed = db.query(ReflectionSession).filter(
        ReflectionSession.user_id == current_user.id,
        ReflectionSession.is_completed == True
    ).count()
    checkins_progress = min(1.0, reflections_completed / 10.0)

    # Openness progress: based on emotional warmth (ratio of warm/hopeful answers)
    total_answers = db.query(ReflectionAnswer).filter(ReflectionAnswer.user_id == current_user.id).count()
    warm_answers = db.query(ReflectionAnswer).filter(
        ReflectionAnswer.user_id == current_user.id,
        ReflectionAnswer.ai_tone.in_(["warm", "hopeful"])
    ).count()
    openness_progress = (warm_answers / total_answers) if total_answers > 0 else 0.4

    # Presence progress: based on mood logging frequency (out of 15 logs max)
    moods_logged = db.query(Mood).filter(Mood.user_id == current_user.id).count()
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
    current_user: User = Depends(get_current_user)
):
    """
    Reveals mature AI-generated insights at the end of the separation day.
    Checks if expected_end_date of the active separation is reached, completed,
    or if both partners completed all reflection days.
    """
    if not current_user.partner_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You must be partnered to generate relationship insights."
        )

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
        ).first()

        if not sep:
            # Fallback check for recently completed separation to allow viewing history
            sep = db.query(Separation).filter(
                (Separation.creator_id == current_user.id) | (Separation.partner_id == current_user.id),
                Separation.status == "completed"
            ).order_by(Separation.ended_at.desc()).first()

    if not sep:
        return {
            "isUnlocked": False,
            "daysRemaining": 99,
            "message": "Start a Separation space to unlock your insights vault.",
            "insights": None
        }

    # 2. Retrieve partner info
    partner = db.query(User).filter(User.id == current_user.partner_id).first()
    partner_name = partner.user_name if (partner and partner.user_name) else "Partner"

    # Count shared completed reflection days
    shared_days = db.query(ReflectionSession.day_number).filter(
        ReflectionSession.user_id == current_user.id,
        ReflectionSession.is_completed == True
    ).intersect(
        db.query(ReflectionSession.day_number).filter(
            ReflectionSession.user_id == partner.id,
            ReflectionSession.is_completed == True
        )
    ).count()

    # Calculate total expected reflection days from duration label
    duration_label = (sep.duration_label or "").lower()
    expected_days = 7  # default
    if "2" in duration_label or "two" in duration_label:
        expected_days = 14
    elif "month" in duration_label or "30" in duration_label:
        expected_days = 30

    # Auto-unlock early if both partners completed all required reflection days
    completed_all_reflections = (shared_days >= expected_days)

    # Check if locked or unlocked
    days_remaining = (sep.expected_end_date - date.today()).days if sep.expected_end_date else 99
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
    ).filter(ReflectionAnswer.user_id == current_user.id).all()
    
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
    ).filter(ReflectionAnswer.user_id == partner.id).all()
    
    partner_ref_data = [
        {
            "question": q.question_text,
            "answer": ans.text_answer,
            "emotion": ans.ai_emotion_detected,
            "tone": ans.ai_tone
        } for ans, q in partner_reflections
    ]

    # Moods during this period
    user_moods = [m.mood for m in db.query(Mood).filter(Mood.user_id == current_user.id).order_by(Mood.created_at.desc()).limit(10).all()]
    partner_moods = [m.mood for m in db.query(Mood).filter(Mood.user_id == partner.id).order_by(Mood.created_at.desc()).limit(10).all()]

    # Total counts
    user_total_days = db.query(ReflectionSession).filter(ReflectionSession.user_id == current_user.id, ReflectionSession.is_completed == True).count()
    partner_total_days = db.query(ReflectionSession).filter(ReflectionSession.user_id == partner.id, ReflectionSession.is_completed == True).count()
    
    shared_days = db.query(ReflectionSession.day_number).filter(
        ReflectionSession.user_id == current_user.id,
        ReflectionSession.is_completed == True
    ).intersect(
        db.query(ReflectionSession.day_number).filter(
            ReflectionSession.user_id == partner.id,
            ReflectionSession.is_completed == True
        )
    ).count()

    user_letters = db.query(Letter).filter(Letter.author_id == current_user.id).count()
    partner_letters = db.query(Letter).filter(Letter.author_id == partner.id).count()

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
    if not sep.closing_insight:
        insights = await generate_journey_insights(current_user.user_name or "You", partner_name, bundle_data)
        
        # Save to DB so we don't regenerate and don't re-trigger push
        sep.closing_insight = json.dumps(insights)
        db.commit()
        
        # Trigger 10: Journey insights generated
        title = "✨ Your Journey Insights Are Ready"
        body = "Your separation period is complete. Review your beautiful insights now."
        
        background_tasks.add_task(
            create_notification_and_push,
            db,
            current_user.id,
            "insights_ready",
            title,
            body,
            current_user.fcm_token
        )
        
        if partner and partner.fcm_token:
            background_tasks.add_task(
                create_notification_and_push,
                db,
                partner.id,
                "insights_ready",
                title,
                body,
                partner.fcm_token
            )
    else:
        try:
            insights = json.loads(sep.closing_insight)
        except Exception:
            insights = {"message": "Could not parse insights."}

    return {
        "isUnlocked": True,
        "daysRemaining": 0,
        "message": "Your insights are successfully unlocked.",
        "insights": insights
    }
