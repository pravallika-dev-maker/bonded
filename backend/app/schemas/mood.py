from datetime import datetime
from typing import Optional
from .auth import BaseSchema

class MoodCreate(BaseSchema):
    mood: str
    reflection: Optional[str] = None

class MoodResponse(BaseSchema):
    id: int
    mood: str
    reflection: Optional[str] = None
    created_at: datetime
    ai_quote: Optional[str] = None     # Gemini-generated emotional quote
    ai_advice: Optional[str] = None    # Gemini-generated personalized advice
    partner_name: Optional[str] = None

    class Config:
        from_attributes = True
