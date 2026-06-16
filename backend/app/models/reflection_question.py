from sqlalchemy import Column, Integer, String, Text, Boolean, ForeignKey
from ..database import Base

class ReflectionQuestion(Base):
    __tablename__ = "reflection_questions"

    id = Column(Integer, primary_key=True, index=True)
    day_number = Column(Integer, nullable=False, unique=True)
    category_id = Column(Integer, ForeignKey("question_categories.id"))
    question_type = Column(String(20), nullable=False) # 'text' or 'situational'
    question_text = Column(String(600), nullable=False)
    scenario_prefix = Column(Text, nullable=True)
    hint_text = Column(String(300), nullable=True)
    is_active = Column(Boolean, default=True)
