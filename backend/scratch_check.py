import sys
import os

# Add backend to path
sys.path.append(os.path.abspath('c:/Users/prava/OneDrive/Desktop/bonding/backend'))

from app.database import SessionLocal
from app.models import User, Separation, ReflectionSession

def check_db():
    db = SessionLocal()
    users = db.query(User).all()
    for u in users:
        sep = db.query(Separation).filter((Separation.creator_id == u.id) | (Separation.partner_id == u.id)).first()
        if not sep: continue
        sessions = db.query(ReflectionSession).filter(ReflectionSession.user_id == u.id).all()
        if sessions:
            print(f"User: {u.email}")
            print(f"Separation Start: {sep.start_date}")
            for s in sessions:
                print(f"  Day: {s.day_number}, Completed: {s.is_completed}, At: {s.completed_at}")
    db.close()

if __name__ == "__main__":
    check_db()
