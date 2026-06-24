import logging
from datetime import date, datetime, timezone, timedelta
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ...database import get_db
from ...schemas.home import HomeHeroResponse
from ..deps import get_current_user
from ...models.user import User
from ...models.relationship import Relationship
from ...models.separation import Separation
import random

router = APIRouter(prefix="/home", tags=["Home"])
logger = logging.getLogger("bonded.api.home")

COMFORT_MESSAGES = [
    "Every quiet moment brings deeper clarity.",
    "Growth often happens in the spaces between conversations.",
    "Distance can create room for understanding.",
    "Patience is the quietest form of love.",
    "True connection deepens even when apart.",
    "This time is a gift of self-discovery.",
    "A step back is sometimes a step forward.",
    "Take this day to nourish your own heart.",
    "Understanding blooms in stillness.",
    "Reflection paves the path to healing."
]

@router.get("/hero", response_model=HomeHeroResponse)
async def get_home_hero(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        # ── Update presence timestamp ──
        now_utc = datetime.now(timezone.utc)
        current_user.last_active_at = now_utc
        try:
            db.commit()
        except Exception:
            db.rollback()

        # Check if partner is connected via an active relationship
        active_rel = db.query(Relationship).filter(
            (Relationship.user1_id == current_user.id) | (Relationship.user2_id == current_user.id),
            Relationship.status == "active"
        ).first()
        # Check for any past relationships
        has_past = db.query(Relationship).filter(
            (Relationship.user1_id == current_user.id) | (Relationship.user2_id == current_user.id)
        ).first() is not None

        # Check for active separation
        active_sep = db.query(Separation).filter(
            (Separation.creator_id == current_user.id) | (Separation.partner_id == current_user.id),
            Separation.status == "active"
        ).order_by(Separation.created_at.desc()).first()

        partner_connected = active_rel is not None
        partner_name = current_user.partner_name
        shared_presence = False
        partner = None

        if active_rel:
            partner_id = active_rel.user2_id if active_rel.user1_id == current_user.id else active_rel.user1_id
            if partner_id and partner_id != current_user.id:
                partner = db.query(User).filter(User.id == partner_id).first()
                if partner and not partner_name and partner.user_name:
                    partner_name = partner.user_name

            # ── Detect shared presence (both active within 90 seconds) ──
            PRESENCE_WINDOW = timedelta(seconds=90)
            if partner and partner.last_active_at:
                partner_active_at = partner.last_active_at
                # Make timezone-aware if naive
                if partner_active_at.tzinfo is None:
                    partner_active_at = partner_active_at.replace(tzinfo=timezone.utc)
                
                time_diff = now_utc - partner_active_at
                shared_presence = timedelta(seconds=0) <= time_diff <= PRESENCE_WINDOW

        # Check for completed separation
        completed_sep = db.query(Separation).filter(
            (Separation.creator_id == current_user.id) | (Separation.partner_id == current_user.id),
            Separation.status == "completed"
        ).order_by(Separation.ended_at.desc()).first()
        has_completed_separation = completed_sep is not None

        # Check for active invite code (waiting for partner)
        from ...models.invite_code import InviteCode
        pending_invite = db.query(InviteCode).filter(
            InviteCode.creator_id == current_user.id,
            InviteCode.is_used == False,
            InviteCode.expires_at > datetime.now(timezone.utc)
        ).first()
        is_waiting = (pending_invite is not None) and (not partner_connected)

        if not active_rel and not active_sep:
            return HomeHeroResponse(
                partner_connected=partner_connected,
                partner_name=partner_name,
                has_past_relationship=has_past,
                shared_presence=shared_presence,
                has_completed_separation=has_completed_separation,
                is_waiting_for_partner=is_waiting,
                has_acknowledged_completion=current_user.has_acknowledged_completion
            )

        if not active_sep:
            return HomeHeroResponse(
                partner_connected=partner_connected,
                partner_name=partner_name,
                has_past_relationship=has_past,
                shared_presence=shared_presence,
                has_completed_separation=has_completed_separation,
                is_waiting_for_partner=is_waiting,
                has_acknowledged_completion=current_user.has_acknowledged_completion
            )

        from ...api.v1.reflections import _day_number
        current_day = _day_number(current_user.id, active_sep, db)
        
        if active_sep.expected_end_date and active_sep.start_date:
            total_days = (active_sep.expected_end_date - active_sep.start_date).days
        else:
            duration_label = (active_sep.duration_label or "").lower()
            total_days = 21  # default
            import re
            match = re.search(r'(\d+)', duration_label)
            if match:
                total_days = int(match.group(1))
            elif "2" in duration_label or "two" in duration_label:
                total_days = 14
            elif "month" in duration_label or "30" in duration_label:
                total_days = 30
                
        if total_days <= 0:
            total_days = 1 # Avoid division by zero
            
        progress_percentage = (current_day / total_days) * 100.0
        if progress_percentage > 100.0:
            progress_percentage = 100.0
            
        # ── Get-or-create today's comfort message (persisted, never regenerated) ──
        from ...models.user_daily_comfort import UserDailyComfort
        today = date.today()

        existing_comfort = db.query(UserDailyComfort).filter(
            UserDailyComfort.user_id == current_user.id,
            UserDailyComfort.comfort_date == today
        ).first()

        if existing_comfort:
            # Return the same quote stored for today — no regeneration
            comfort_message = existing_comfort.text
        else:
            # First call today: generate and persist
            comfort_message = random.choice(COMFORT_MESSAGES)
            try:
                from ...services.ai_service import _get_client
                client = _get_client()
                prompt = (
                    "Generate a single, very short comforting message (1 sentence) for someone "
                    "in a relationship separation journey. It should be warm, supportive, and easy "
                    "to understand. Examples: 'Every quiet moment brings deeper clarity.' or "
                    "'Distance can create room for understanding.'"
                )
                response = await client.aio.models.generate_content(
                    model='gemini-2.5-flash',
                    contents=prompt,
                )
                text = response.text.strip().strip('"').strip()
                if text:
                    comfort_message = text
            except Exception as e:
                logger.error(f"Gemini comfort_message generation failed: {e}")

            # Persist so every subsequent call today returns the same quote
            new_comfort = UserDailyComfort(
                user_id=current_user.id,
                comfort_date=today,
                text=comfort_message
            )
            db.add(new_comfort)
            try:
                db.commit()
            except Exception:
                db.rollback()

        from ...api.v1.reflections import _get_logical_date
        today_logical = _get_logical_date()
        start_logical = _get_logical_date(active_sep.start_date) if active_sep.start_date else today_logical
        calendar_day = (today_logical - start_logical).days + 1
        if calendar_day < 1:
            calendar_day = 1
            
        is_missed_day_flow = current_day < calendar_day

        if is_missed_day_flow:
            comfort_message = "It's okay to take a break. Take your time catching up, one step at a time."

        return HomeHeroResponse(
            partner_connected=partner_connected,
            partner_name=partner_name,
            current_day=current_day,
            total_duration_days=total_days,
            progress_percentage=round(progress_percentage, 2),
            comfort_message=comfort_message,
            has_past_relationship=has_past,
            is_missed_day_flow=is_missed_day_flow,
            shared_presence=shared_presence,
            has_completed_separation=has_completed_separation,
            is_waiting_for_partner=is_waiting,
            has_acknowledged_completion=current_user.has_acknowledged_completion
        )


    except Exception as e:
        logger.error(f"Error fetching home hero: {e}")
        raise HTTPException(status_code=500, detail="Could not fetch home hero data")

@router.post("/acknowledge-completion")
async def acknowledge_completion(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        current_user.has_acknowledged_completion = True
        db.commit()
        return {"success": True}
    except Exception as e:
        db.rollback()
        logger.error(f"Error acknowledging completion: {e}")
        raise HTTPException(status_code=500, detail="Could not acknowledge completion")

@router.post("/offline")
async def set_offline(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        # Clear the last_active_at timestamp to immediately remove the presence signal
        current_user.last_active_at = None
        db.commit()
        return {"success": True}
    except Exception as e:
        db.rollback()
        logger.error(f"Error setting offline status: {e}")
        raise HTTPException(status_code=500, detail="Could not set offline status")
