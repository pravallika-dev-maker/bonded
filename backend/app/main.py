import os
import logging
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from slowapi import Limiter
from slowapi.util import get_remote_address
from dotenv import load_dotenv

from .api.v1 import auth, users, moods, partners, separations, reflections, letters, journey, notifications
from .database import engine, Base
from .models import user, mood, invite_code, separation, notification, question_category, reflection_question, reflection_session, reflection_answer, reflection_comparison, letter  # Register models

load_dotenv()

logger = logging.getLogger("bonded")

# ── Rate Limiter ──────────────────────────────────────────────────────────────
limiter = Limiter(key_func=get_remote_address, default_limits=["60/minute"])

# ── Scheduler ─────────────────────────────────────────────────────────────────
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from contextlib import asynccontextmanager

def send_daily_reflection_reminders():
    from .database import SessionLocal
    from .models.user import User
    from .services.notification_service import create_notification_and_push
    
    db = SessionLocal()
    try:
        # Get all users with FCM tokens
        users = db.query(User).filter(User.fcm_token.isnot(None)).all()
        for user in users:
            create_notification_and_push(
                db=db,
                recipient_id=user.id,
                notification_type="daily_reminder",
                title="Time to check in 🌙",
                body="Take a quiet moment to reflect on today.",
                fcm_token=user.fcm_token
            )
    except Exception as e:
        logger.error(f"Error sending daily reminders: {e}")
    finally:
        db.close()

@asynccontextmanager
async def lifespan(app: FastAPI):
    scheduler = BackgroundScheduler()
    # Trigger 8: Daily reminder at 8 PM (20:00)
    scheduler.add_job(
        send_daily_reflection_reminders,
        trigger=CronTrigger(hour=20, minute=0),
        id="daily_reminder_job",
        replace_existing=True
    )
    scheduler.start()
    yield
    scheduler.shutdown()

# ── App ───────────────────────────────────────────────────────────────────────
app = FastAPI(title="Bonded API", version="1.0.0", lifespan=lifespan)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.exception(f"Unhandled error occurred: {exc}")
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal Server Error"}
    )

app.add_middleware(SlowAPIMiddleware)

# ── CORS ──────────────────────────────────────────────────────────────────────
allowed_origins = os.getenv("ALLOWED_ORIGINS", "").split(",")
allowed_origins = [o.strip() for o in allowed_origins if o.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Routers ───────────────────────────────────────────────────────────────────
app.include_router(auth.router, prefix="/api/v1")
app.include_router(users.router, prefix="/api/v1")
app.include_router(moods.router, prefix="/api/v1")
app.include_router(partners.router, prefix="/api/v1")
app.include_router(separations.router, prefix="/api/v1")
app.include_router(reflections.router, prefix="/api/v1")
app.include_router(letters.router, prefix="/api/v1")
app.include_router(journey.router, prefix="/api/v1")
app.include_router(notifications.router, prefix="/api/v1")


@app.get("/")
async def root():
    return {"message": "Bonded Backend is running 🚀", "docs": "/docs"}


@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring and deployment probes."""
    try:
        from .database import SessionLocal
        db = SessionLocal()
        db.execute("SELECT 1")
        db.close()
        db_status = "healthy"
    except Exception:
        db_status = "unhealthy"
    return {"status": "ok", "database": db_status}
