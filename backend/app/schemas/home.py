from pydantic import BaseModel
from typing import Optional

class HomeHeroResponse(BaseModel):
    partner_connected: bool
    partner_name: Optional[str] = None
    current_day: Optional[int] = None
    total_duration_days: Optional[int] = None
    progress_percentage: Optional[float] = None
    comfort_message: Optional[str] = None
    has_past_relationship: bool = False
    is_missed_day_flow: bool = False
    shared_presence: bool = False
    has_completed_separation: bool = False
    is_waiting_for_partner: bool = False
    has_acknowledged_completion: bool = False

    class Config:
        from_attributes = True
