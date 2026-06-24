import sys
import os
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))
from datetime import datetime, timezone

from app.database import SessionLocal
from app.models.user import User
from app.models.mood import Mood

db = SessionLocal()
try:
    user = db.query(User).filter(User.phone_number == '8888888888').first()
    if not user:
        print('User not found')
        sys.exit(0)
    
    print(f'Found user: {user.id} ({user.user_name})')
    
    today = datetime.now(timezone.utc).date()
    
    # Find today\'s mood
    moods = db.query(Mood).filter(Mood.user_id == user.id).all()
    deleted = 0
    for m in moods:
        if m.created_at.date() == today:
            db.delete(m)
            deleted += 1
            
    if deleted > 0:
        db.commit()
        print(f'Deleted {deleted} mood(s) for today.')
    else:
        print('No moods found for today.')
except Exception as e:
    print(f'Error: {e}')
finally:
    db.close()
