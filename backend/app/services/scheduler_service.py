import logging
from datetime import datetime, date, timezone, timedelta
from ..database import SessionLocal
from ..models.user import User
from ..models.mood import Mood
from ..models.separation import Separation
from ..models.reflection_session import ReflectionSession
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
                    title="Daily Check-In",
                    body="✨ Take a moment to check in with yourself today.",
                    fcm_token=user.fcm_token
                )
    except Exception as e:
        logger.error(f"Error in run_evening_checkin_nudge: {e}")
    finally:
        db.close()

def run_evening_reflection_nudge():
    """
    Runs daily to check if users in an active separation have completed their daily reflection.
    If not, sends a gentle reminder.
    """
    db = SessionLocal()
    try:
        today_start = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)
        
        # Get users in active separations
        active_seps = db.query(Separation).filter(Separation.status == 'active').all()
        user_ids_in_sep = set()
        for sep in active_seps:
            if sep.creator_id: user_ids_in_sep.add(sep.creator_id)
            if sep.partner_id: user_ids_in_sep.add(sep.partner_id)
            
        if user_ids_in_sep:
            users = db.query(User).filter(User.id.in_(user_ids_in_sep), User.fcm_token.isnot(None)).all()
            for user in users:
                # Check if user completed a reflection today
                has_reflection_today = db.query(ReflectionSession).filter(
                    ReflectionSession.user_id == user.id,
                    ReflectionSession.is_completed == True,
                    ReflectionSession.completed_at >= today_start
                ).first() is not None
                
                if not has_reflection_today:
                    create_notification_and_push(
                        db=db,
                        recipient_id=user.id,
                        notification_type="daily_reminder",
                        title="Daily Reflection",
                        body="🌙 Today's reflection is waiting whenever you're ready.",
                        fcm_token=user.fcm_token
                    )
    except Exception as e:
        logger.error(f"Error in run_evening_reflection_nudge: {e}")
    finally:
        db.close()


def run_journey_milestones_check():
    """
    Runs daily to check for Journey Milestones (Days 3, 7, 14, 21, 30, 50%, 100%).
    """
    db = SessionLocal()
    try:
        seps = db.query(Separation).filter(Separation.status == 'active').all()
        for sep in seps:
            if not sep.start_date or not sep.expected_end_date:
                continue
                
            total_duration = (sep.expected_end_date - sep.start_date).days
            if total_duration <= 0:
                continue
                
            halfway_day = total_duration // 2
            days_elapsed = (date.today() - sep.start_date).days + 1
            
            message = None
            if days_elapsed in [3, 7, 14, 21, 30]:
                message = "✨ Another meaningful milestone reached."
            elif days_elapsed == halfway_day:
                message = "💛 You're halfway through your journey."
            elif days_elapsed == total_duration:
                message = "🌱 You're making steady progress together."
                
            if message:
                for uid in [sep.creator_id, sep.partner_id]:
                    if uid:
                        u = db.query(User).filter(User.id == uid).first()
                        if u and u.fcm_token:
                            create_notification_and_push(
                                db=db,
                                recipient_id=u.id,
                                notification_type="journey_milestone",
                                title="Journey Milestone",
                                body=message,
                                fcm_token=u.fcm_token
                            )
    except Exception as e:
        logger.error(f"Error in run_journey_milestones_check: {e}")
    finally:
        db.close()

def run_reengagement_nudge():
    """
    Runs daily to find users inactive for 2-3 days and send a gentle nudge.
    """
    import random
    db = SessionLocal()
    try:
        two_days_ago = datetime.now(timezone.utc) - timedelta(days=2)
        three_days_ago = datetime.now(timezone.utc) - timedelta(days=3)
        
        users = db.query(User).filter(User.fcm_token.isnot(None)).all()
        for user in users:
            last_mood = db.query(Mood).filter(Mood.user_id == user.id).order_by(Mood.created_at.desc()).first()
            last_ref = db.query(ReflectionSession).filter(ReflectionSession.user_id == user.id, ReflectionSession.is_completed == True).order_by(ReflectionSession.completed_at.desc()).first()
            
            last_activity_date = None
            if last_mood and last_mood.created_at:
                last_activity_date = last_mood.created_at
            if last_ref and last_ref.completed_at:
                if not last_activity_date or last_ref.completed_at > last_activity_date:
                    last_activity_date = last_ref.completed_at
                    
            if last_activity_date and three_days_ago <= last_activity_date <= two_days_ago:
                message = random.choice([
                    "💭 What has been sitting in your heart lately?",
                    "🌱 A small reflection today can change tomorrow."
                ])
                create_notification_and_push(
                    db=db,
                    recipient_id=user.id,
                    notification_type="reengagement",
                    title="Thinking of you",
                    body=message,
                    fcm_token=user.fcm_token
                )
    except Exception as e:
        logger.error(f"Error in run_reengagement_nudge: {e}")
    finally:
        db.close()
