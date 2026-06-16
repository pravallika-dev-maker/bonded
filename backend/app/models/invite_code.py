from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from datetime import datetime, timedelta, timezone
from ..database import Base

class InviteCode(Base):
    __tablename__ = "invite_codes"

    id = Column(Integer, primary_key=True, index=True)
    code = Column(String(20), unique=True, index=True, nullable=False)
    creator_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    is_used = Column(Boolean, default=False)
    expires_at = Column(DateTime, nullable=False, default=lambda: datetime.now(timezone.utc) + timedelta(hours=24))
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
