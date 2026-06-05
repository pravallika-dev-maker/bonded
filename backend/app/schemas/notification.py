from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel
from datetime import datetime
from typing import Optional

class BaseSchema(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,
        from_attributes=True,
    )

class NotificationResponse(BaseSchema):
    id: int
    notification_type: str
    title: str
    body: Optional[str] = None
    is_read: bool
    created_at: datetime

class UnreadCountResponse(BaseSchema):
    unread_count: int
