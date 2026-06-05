from sqlalchemy import Column, Integer, Text, String, Boolean, DateTime, ForeignKey
from datetime import datetime, timezone
from ..database import Base

class ReflectionAnswer(Base):
    __tablename__ = "reflection_answers"

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("reflection_sessions.id", ondelete="CASCADE"))
    user_id = Column(Integer, ForeignKey("users.id"))
    question_id = Column(Integer, ForeignKey("reflection_questions.id"))
    
    text_answer = Column(Text, nullable=True)
    
    ai_emotion_detected = Column(String(50), nullable=True)
    ai_tone = Column(String(30), nullable=True)
    ai_reaction_text = Column(Text, nullable=True)
    ai_processed = Column(Boolean, default=False)
    
    answered_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
