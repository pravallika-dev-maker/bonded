import random
import logging
from sqlalchemy.orm import Session
from ..models.user import User

logger = logging.getLogger("bonded.auth")


class AuthService:
    @staticmethod
    def generate_otp() -> str:
        return str(random.randint(100000, 999999))

    @staticmethod
    async def send_sms_otp(phone_number: str, otp: str):
        logger.info(f"[SMS SERVICE] Sending OTP to {phone_number}")
        # TODO: Integrate Twilio/MessageBird for production SMS delivery
        return True

    @staticmethod
    async def verify_otp(db: Session, phone_number: str, country_code: str, otp: str) -> bool:
        # TODO: Replace with real OTP verification (Redis-backed, expiring)
        if otp != "123456":
            return False
            
        user = db.query(User).filter(User.phone_number == phone_number).first()
        if not user:
            logger.info(f"Creating new user for phone: {phone_number}")
            user = User(
                phone_number=phone_number,
                country_code=country_code,
                is_active=True
            )
            db.add(user)
            db.commit()
            db.refresh(user)
        else:
            logger.info(f"Existing user logged in: {phone_number}")
            
        return True
