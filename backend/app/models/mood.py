from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.sql import func
from ..database import Base

class Mood(Base):
    __tablename__ = "moods"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    mood = Column(String, nullable=False) # e.g., 'longing', 'peaceful'
    reflection = Column(Text, nullable=True)
    ai_quote = Column(Text, nullable=True)   # Gemini-generated emotional quote
    ai_advice = Column(Text, nullable=True)  # Gemini-generated personalized advice
    created_at = Column(DateTime(timezone=True), server_default=func.now())
