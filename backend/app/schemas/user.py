from typing import Optional
from .auth import BaseSchema

class UserProfileUpdate(BaseSchema):
    userName: Optional[str] = None
    relationType: Optional[str] = None
    partnerName: Optional[str] = None
    relationshipDate: Optional[str] = None # ISO format string
    dob: Optional[str] = None # ISO format string
    gender: Optional[str] = None

class FCMTokenUpdate(BaseSchema):
    fcmToken: str

