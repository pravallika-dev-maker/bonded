from pydantic import BaseModel
from typing import List, Optional
from datetime import date, datetime

class RelationshipHistoryItem(BaseModel):
    relationship_id: int
    partner_name: Optional[str]
    partner_gender: Optional[str] = None
    status: str
    journey_score: int
    separation_count: int
    started_at: Optional[datetime]
    ended_at: Optional[datetime]
    relationship_type: Optional[str] = None

    class Config:
        from_attributes = True

class RelationshipSummaryResponse(BaseModel):
    relationship_id: int
    partner_name: Optional[str]
    partner_gender: Optional[str] = None
    journey_score: int
    separation_count: int
    relationship_duration_days: int
    status: str
    relationship_type: Optional[str] = None
    relationship_summary: Optional[str] = None


