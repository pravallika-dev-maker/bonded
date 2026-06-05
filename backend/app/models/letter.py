from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, Boolean
from sqlalchemy.sql import func
from ..database import Base

class Letter(Base):
    __tablename__ = "letters"

    id = Column(Integer, primary_key=True, index=True)
    author_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    partner_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=True)
    
    title = Column(String(255), nullable=True)
    content = Column(Text, nullable=False)
    letter_type = Column(String(50), nullable=True) # Optional now
    ai_love_score = Column(Integer, default=0) # 0 to 100
    
    is_revealed = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
