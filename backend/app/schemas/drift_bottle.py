from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class DriftBottleStatusResponse(BaseModel):
    can_open: bool
    last_opened: Optional[datetime] = None


class UserRewardsResponse(BaseModel):
    love_tokens: int
    aura_fragments: int


class DriftBottleOpenResponse(BaseModel):
    success: bool
    message: Optional[str] = None
    reward_type: Optional[str] = None
    reward_value: Optional[int] = None
    total_love_tokens: Optional[int] = None
    total_aura_fragments: Optional[int] = None
