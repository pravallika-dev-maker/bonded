from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from datetime import datetime, timezone
from ..database import Base

class Poke(Base):
    __tablename__ = "pokes"

    id = Column(Integer, primary_key=True, index=True)
    sender_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    recipient_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    gesture = Column(String(50), nullable=False)  # e.g., "Love", "Hug", "Kiss", "Flower", "Sparkle", "Sunshine"
    is_acknowledged = Column(Boolean, default=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
