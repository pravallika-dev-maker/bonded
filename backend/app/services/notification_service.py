import logging
from sqlalchemy.orm import Session
from firebase_admin import messaging
from ..models.notification import Notification
from ..core.firebase import get_firebase_app

logger = logging.getLogger("bonded.notifications")

def create_notification(db: Session, recipient_id: int, notification_type: str, title: str, body: str = None):
    try:
        notif = Notification(
            recipient_id=recipient_id, 
            notification_type=notification_type,
            title=title, 
            body=body
        )
        db.add(notif)
        db.commit()
        db.refresh(notif)
        return notif
    except Exception as e:
        logger.error(f"Failed to create notification for user {recipient_id}: {e}")
        db.rollback()
        return None

def send_push(fcm_token: str, title: str, body: str) -> bool:
    if not fcm_token:
        logger.info("FCM push skipped: No FCM token provided for user.")
        return False
        
    app = get_firebase_app()
    if app == "MOCK" or app is None:
        logger.info(f"[FCM MOCK PUSH] To Token: {fcm_token} | Title: {title} | Body: {body}")
        return True
        
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            # ── Android: HIGH priority + default sound → forces Heads-Up banner ──
            android=messaging.AndroidConfig(
                priority="high",
                notification=messaging.AndroidNotification(
                    sound="default",
                    channel_id="bonded_urgent_alerts",
                    default_sound=True,
                    default_vibrate_timings=True,
                ),
            ),
            # ── iOS: critical-style alert + sound → forces banner even in foreground ──
            apns=messaging.APNSConfig(
                headers={"apns-priority": "10"},
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(
                        alert=messaging.ApsAlert(title=title, body=body),
                        sound="default",
                        badge=1,
                    )
                ),
            ),
            token=fcm_token,
        )
        logger.info(f"🔥 [BACKEND SEND] Building FCM Message for token {fcm_token[:10]}...")
        logger.info(f"🔥 [BACKEND SEND] Payload Notification: title='{title}', body='{body}'")
        logger.info(f"🔥 [BACKEND SEND] Android Priority: high, Channel: bonded_urgent_alerts")
        response = messaging.send(message)
        logger.info(f"FCM push sent successfully: {response}")
        return True
    except Exception as e:
        logger.error(f"Failed to send FCM push notification: {e}")
        return False

def create_notification_and_push(
    db: Session,
    recipient_id: int,
    notification_type: str,
    title: str,
    body: str = None,
    fcm_token: str = None
):
    # 1. Create DB notification first
    notif = None
    try:
        notif = Notification(
            recipient_id=recipient_id,
            notification_type=notification_type,
            title=title,
            body=body,
            push_sent=False
        )
        db.add(notif)
        db.commit()
        db.refresh(notif)
    except Exception as e:
        logger.error(f"Failed to create DB notification for user {recipient_id}: {e}")
        db.rollback()
        
    # 2. Try sending push notification if fcm_token is available
    if fcm_token and notif:
        success = send_push(fcm_token, title, body or "")
        if success:
            try:
                notif.push_sent = True
                db.commit()
            except Exception as e:
                logger.error(f"Failed to update push_sent status in DB: {e}")
                db.rollback()
                
    return notif
