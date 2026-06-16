from datetime import datetime
from typing import Optional
from .auth import BaseSchema

class NotificationResponse(BaseSchema):
    id: int
    notification_type: str
    title: str
    body: Optional[str] = None
    is_read: bool
    created_at: datetime

class UnreadCountResponse(BaseSchema):
    unread_count: int
