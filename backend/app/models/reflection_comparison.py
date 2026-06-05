from sqlalchemy import Column, Integer, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB
from datetime import datetime, timezone
from ..database import Base

class ReflectionComparison(Base):
    __tablename__ = "reflection_comparisons"

    id = Column(Integer, primary_key=True, index=True)
    separation_id = Column(Integer, ForeignKey("separations.id"))
    day_number = Column(Integer, nullable=False)
    user_a_session_id = Column(Integer, ForeignKey("reflection_sessions.id"))
    user_b_session_id = Column(Integer, ForeignKey("reflection_sessions.id"))
    
    comparison_data = Column(JSONB, nullable=True)
    suggestions = Column(JSONB, nullable=True)
    
    generated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    __table_args__ = (
        UniqueConstraint('separation_id', 'day_number', name='uq_sep_day'),
    )
