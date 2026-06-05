from pydantic import BaseModel
from datetime import date, datetime
from typing import Optional
from .partner import BaseSchema

class SeparationCreate(BaseSchema):
    duration_label: str
    start_date: str # Send from frontend as YYYY-MM-DD
    reason: Optional[str] = None

class SeparationResponse(BaseSchema):
    id: int
    creator_id: int
    partner_id: Optional[int]
    duration_label: str
    start_date: date
    reason: Optional[str]
    status: str
    closing_insight: Optional[str]
    expected_end_date: Optional[date] = None
    ended_at: Optional[datetime]
    created_at: datetime
    days_elapsed: int = 0
    partner_name: Optional[str] = None
    
    class Config:
        from_attributes = True

class ActiveSeparationResponse(BaseSchema):
    is_active: bool
    days_elapsed: int = 0
    mood_phrase: str = "Continuing to grow"
    partner_name: Optional[str] = None
