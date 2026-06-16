from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.reflection_session import ReflectionSession
from app.models.mood import Mood
from app.models.reflection_answer import ReflectionAnswer

db = SessionLocal()

# We want to delete all reflection sessions and moods except the very latest ones for each user
users = [1, 2] # Assuming user 1 and 2

for user_id in users:
    print(f"Cleaning user {user_id}")
    
    # 1. Clean Reflection Sessions
    sessions = db.query(ReflectionSession).filter(ReflectionSession.user_id == user_id).order_by(ReflectionSession.created_at.desc()).all()
    if len(sessions) > 1:
        # Keep the FIRST one (which is the most recent) or the one with day_number 1?
        # Actually, let's keep the one that was created TODAY or the most recent one.
        for s in sessions[1:]:
            print(f"Deleting session {s.id} (day {s.day_number})")
            db.delete(s)
            
    # 2. Clean Moods
    moods = db.query(Mood).filter(Mood.user_id == user_id).order_by(Mood.created_at.desc()).all()
    if len(moods) > 1:
        for m in moods[1:]:
            print(f"Deleting mood {m.id}")
            db.delete(m)

db.commit()
print("Done cleaning!")
