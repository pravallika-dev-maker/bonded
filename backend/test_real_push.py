import sys
import os
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from app.database import SessionLocal
from app.models.user import User
from app.services.notification_service import send_push
import logging

logging.basicConfig(level=logging.INFO)

db = SessionLocal()
try:
    user = db.query(User).filter(User.phone_number == '7416805948').first()
    if not user:
        print('User not found')
        sys.exit(0)
    
    if not user.fcm_token:
        print('User does not have an fcm_token!')
        sys.exit(0)
        
    print(f'Sending test push to user {user.phone_number} with token {user.fcm_token[:15]}...')
    success = send_push(user.fcm_token, "Test Push", "This is a direct test from the server.")
    print(f'Push success: {success}')
except Exception as e:
    print(f'Error: {e}')
finally:
    db.close()
