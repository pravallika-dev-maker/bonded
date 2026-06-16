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
from sqlalchemy import text
from dotenv import load_dotenv

from .api.v1 import auth, users, moods, partners, separations, reflections, letters, journey, notifications, daily_content, relationships, home
from .database import engine, Base
from .models import user, mood, invite_code, separation, notification, question_category, reflection_question, reflection_session, reflection_answer, reflection_comparison, letter, user_daily_affirmation, user_daily_insight  # Register models

load_dotenv()

logger = logging.getLogger("bonded")

# ── Rate Limiter ──────────────────────────────────────────────────────────────
limiter = Limiter(key_func=get_remote_address, default_limits=["60/minute"])

# ── Scheduler ─────────────────────────────────────────────────────────────────
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from contextlib import asynccontextmanager

from .services.scheduler_service import run_evening_checkin_nudge, run_halfway_mark_encouragement

from apscheduler.jobstores.sqlalchemy import SQLAlchemyJobStore
from .database import SQLALCHEMY_DATABASE_URL

@asynccontextmanager
async def lifespan(app: FastAPI):
    jobstores = {
        'default': SQLAlchemyJobStore(url=SQLALCHEMY_DATABASE_URL)
    }
    scheduler = BackgroundScheduler(jobstores=jobstores)
    
    # 1. Evening Check-in Nudge at 20:00 (8:00 PM)
    scheduler.add_job(
        run_evening_checkin_nudge,
        trigger=CronTrigger(hour=20, minute=0),
        id="evening_checkin_nudge_job",
        replace_existing=True
    )
    
    # 2. Halfway Mark Encouragement at 12:00 PM
    scheduler.add_job(
        run_halfway_mark_encouragement,
        trigger=CronTrigger(hour=12, minute=0),
        id="halfway_mark_encouragement_job",
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

# ── Middleware (order matters: LAST added = FIRST to run) ─────────────────────
# SlowAPI must be added BEFORE CORS so that CORS runs first on incoming requests.
# This ensures OPTIONS preflight gets CORS headers before SlowAPI can reject it.
app.add_middleware(SlowAPIMiddleware)

# CORS — added LAST so it runs FIRST.
# For mobile-only backend: allow all origins since native apps don't send Origin headers.
# If you add a web frontend later, set ALLOWED_ORIGINS env var to your domain(s).
allowed_origins_str = os.getenv("ALLOWED_ORIGINS", "*")
if allowed_origins_str.strip() == "*":
    allowed_origins = ["*"]
else:
    allowed_origins = [o.strip() for o in allowed_origins_str.split(",") if o.strip()]

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
app.include_router(daily_content.router, prefix="/api/v1")
app.include_router(relationships.router, prefix="/api/v1")
app.include_router(home.router, prefix="/api/v1")


@app.get("/")
async def root():
    return {"message": "Bonded Backend is running 🚀", "docs": "/docs"}


@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring and deployment probes."""
    try:
        from .database import SessionLocal
        db = SessionLocal()
        db.execute(text("SELECT 1"))
        db.close()
        db_status = "healthy"
    except Exception:
        db_status = "unhealthy"
    return {"status": "ok", "database": db_status}
