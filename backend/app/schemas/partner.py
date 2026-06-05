from pydantic import BaseModel
from datetime import datetime

# To support camelCase responses to Flutter
class BaseSchema(BaseModel):
    class Config:
        populate_by_name = True
        alias_generator = lambda string: "".join(
            word.capitalize() if i > 0 else word 
            for i, word in enumerate(string.split("_"))
        )

class InviteCodeResponse(BaseSchema):
    code: str
    expires_at: datetime
    success: bool = True

class JoinRequest(BaseSchema):
    code: str

class JoinResponse(BaseSchema):
    success: bool
    partner_name: str | None = None
    message: str

class PartnerMeResponse(BaseSchema):
    partner_name: str | None = None
    is_connected: bool
