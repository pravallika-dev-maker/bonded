import logging
from datetime import datetime, date, timezone, timedelta
from ..database import SessionLocal
from ..models.user import User
from ..models.mood import Mood
from ..models.separation import Separation
from ..services.notification_service import create_notification_and_push

logger = logging.getLogger("bonded.scheduler")

def run_evening_checkin_nudge():
    """
    Runs at 20:00. Checks if users have logged a mood today.
    If not, sends a gentle check-in nudge.
    """
    db = SessionLocal()
    try:
        today_start = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)
        
        users = db.query(User).filter(User.fcm_token.isnot(None)).all()
        for user in users:
            # Check if user logged a mood today
            has_mood_today = db.query(Mood).filter(
                Mood.user_id == user.id,
                Mood.created_at >= today_start
            ).first() is not None
            
            if not has_mood_today:
                create_notification_and_push(
                    db=db,
                    recipient_id=user.id,
                    notification_type="daily_reminder",
                    title="Time to check in 🌙",
                    body="Take a deep breath. How is your heart feeling today? 🌿",
                    fcm_token=user.fcm_token
                )
    except Exception as e:
        logger.error(f"Error in run_evening_checkin_nudge: {e}")
    finally:
        db.close()

def run_halfway_mark_encouragement():
    """
    Runs daily (e.g., at 12:00 PM). Finds active separations that are exactly at the halfway mark.
    """
    db = SessionLocal()
    try:
        # Find all active separations
        seps = db.query(Separation).filter(Separation.status == 'active').all()
        for sep in seps:
            if not sep.start_date or not sep.expected_end_date:
                continue
                
            # Calculate total duration in days
            total_duration = (sep.expected_end_date - sep.start_date).days
            if total_duration <= 0:
                continue
                
            # Calculate halfway point
            halfway_day = total_duration // 2
            
            # Current day (1-indexed)
            days_elapsed = (date.today() - sep.start_date).days + 1
            
            # If today is exactly the halfway day, send notification
            if days_elapsed == halfway_day:
                message = "You are halfway through your space. Keep focusing on your beautiful personal growth. ✨"
                
                # Notify creator
                if sep.creator_id:
                    creator = db.query(User).filter(User.id == sep.creator_id).first()
                    if creator and creator.fcm_token:
                        create_notification_and_push(
                            db=db,
                            recipient_id=creator.id,
                            notification_type="halfway_mark",
                            title="Halfway There 🌿",
                            body=message,
                            fcm_token=creator.fcm_token
                        )
                
                # Notify partner
                if sep.partner_id:
                    partner = db.query(User).filter(User.id == sep.partner_id).first()
                    if partner and partner.fcm_token:
                        create_notification_and_push(
                            db=db,
                            recipient_id=partner.id,
                            notification_type="halfway_mark",
                            title="Halfway There 🌿",
                            body=message,
                            fcm_token=partner.fcm_token
                        )
    except Exception as e:
        logger.error(f"Error in run_halfway_mark_encouragement: {e}")
    finally:
        db.close()
