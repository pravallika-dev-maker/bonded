from sqlalchemy import Column, Integer, String, Boolean, DateTime, Date, ForeignKey
from datetime import datetime, timezone
from ..database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    phone_number = Column(String, unique=True, index=True)
    country_code = Column(String)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    
    # New Profile Fields (collected after OTP)
    user_name = Column(String, nullable=True)
    relation_type = Column(String, nullable=True)
    partner_name = Column(String, nullable=True)
    relationship_date = Column(Date, nullable=True)
    dob = Column(Date, nullable=True)
    partner_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    is_partnered = Column(Boolean, default=False)
    gender = Column(String, nullable=True)
    relationship_score = Column(Integer, default=0)
    fcm_token = Column(String, nullable=True)

