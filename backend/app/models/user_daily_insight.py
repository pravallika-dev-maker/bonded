from sqlalchemy import Column, Integer, String, Date, DateTime, Boolean, ForeignKey, UniqueConstraint
from sqlalchemy.sql import func
from ..database import Base

class UserDailyInsight(Base):
    __tablename__ = "user_daily_insights"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    insight_date = Column(Date, nullable=False, index=True)
    text = Column(String, nullable=False)
    is_viewed = Column(Boolean, nullable=False, default=False)
    viewed_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (
        UniqueConstraint('user_id', 'insight_date', name='uq_user_daily_insight'),
    )

