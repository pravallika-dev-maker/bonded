from datetime import date, datetime
from typing import Optional
from pydantic import Field
from .auth import BaseSchema

class SeparationCreate(BaseSchema):
    duration_label: str = Field(..., max_length=50)
    start_date: str
    reason: Optional[str] = Field(None, max_length=2000)

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

class ActiveSeparationResponse(BaseSchema):
    is_active: bool
    id: Optional[int] = None
    duration_label: Optional[str] = None
    start_date: Optional[date] = None
    expected_end_date: Optional[date] = None
    reason: Optional[str] = None
    days_elapsed: int = 0
    mood_phrase: str = "Continuing to grow"
    partner_name: Optional[str] = None
