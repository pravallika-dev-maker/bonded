from sqlalchemy import Column, Integer, String, Date, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.sql import func
from ..database import Base


class UserDailyComfort(Base):
    """Stores one comfort/hero quote per user per day so it never regenerates on refresh."""
    __tablename__ = "user_daily_comforts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    comfort_date = Column(Date, nullable=False, index=True)
    text = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (
        UniqueConstraint('user_id', 'comfort_date', name='uq_user_daily_comfort'),
    )
