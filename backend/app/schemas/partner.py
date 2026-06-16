from datetime import datetime, date
from typing import Optional
from pydantic import Field
from .auth import BaseSchema

class InviteCodeResponse(BaseSchema):
    code: str
    expires_at: datetime
    success: bool = True

class JoinRequest(BaseSchema):
    code: str = Field(..., max_length=20)

class JoinResponse(BaseSchema):
    success: bool
    partner_name: Optional[str] = None
    message: str

class PartnerMeResponse(BaseSchema):
    is_connected: bool
    partner_id: Optional[int] = None
    partner_name: Optional[str] = None
    gender: Optional[str] = None
    relation_type: Optional[str] = None
    relationship_date: Optional[date] = None
    relationship_score: Optional[int] = None
