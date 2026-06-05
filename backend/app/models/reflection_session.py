from sqlalchemy import Column, Integer, Boolean, DateTime, ForeignKey, UniqueConstraint
from datetime import datetime, timezone
from ..database import Base

class ReflectionSession(Base):
    __tablename__ = "reflection_sessions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    separation_id = Column(Integer, ForeignKey("separations.id", ondelete="SET NULL"), nullable=True)
    day_number = Column(Integer, nullable=False)
    is_completed = Column(Boolean, default=False)
    completed_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    __table_args__ = (
        UniqueConstraint('user_id', 'day_number', 'separation_id', name='uq_user_day_sep'),
    )
