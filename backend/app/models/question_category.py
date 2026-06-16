from sqlalchemy import Column, Integer, String, Text
from ..database import Base

class QuestionCategory(Base):
    __tablename__ = "question_categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    color_hex = Column(String(10), nullable=True)
    sort_order = Column(Integer, default=0)
