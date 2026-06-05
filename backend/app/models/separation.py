from sqlalchemy import Column, Integer, String, Date, Text, DateTime, ForeignKey
from datetime import datetime, timezone
from ..database import Base

class Separation(Base):
    __tablename__ = "separations"

    id = Column(Integer, primary_key=True, index=True)
    creator_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    partner_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    duration_label = Column(String(50))
    start_date = Column(Date, nullable=False)
    reason = Column(Text, nullable=True)
    status = Column(String(20), default="active")
    closing_insight = Column(Text, nullable=True)
    expected_end_date = Column(Date, nullable=True)
    ended_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
