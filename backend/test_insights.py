import asyncio
import os
import sys

sys.path.append("C:\\Users\\prava\\OneDrive\\Desktop\\bonding\\backend")

from app.database import SessionLocal
from app.models.user import User
from app.models.separation import Separation
from app.api.v1.journey import get_journey_insights
from fastapi import BackgroundTasks

async def run():
    db = SessionLocal()
    # Find user 4 (creator of sep 24 or 71)
    user = db.query(User).filter(User.id == 4).first()
    sep = db.query(Separation).filter(Separation.creator_id == user.id, Separation.status == "completed").order_by(Separation.id.desc()).first()
    
    if not user or not sep:
        print("User or sep not found")
        return
        
    print(f"Testing with user {user.id} and sep {sep.id}")
    try:
        class DummyRel:
            id = sep.relationship_id
            
        res = await get_journey_insights(
            background_tasks=BackgroundTasks(),
            separation_id=sep.id,
            db=db,
            current_user=user,
            active_rel=DummyRel()
        )
        print("Result:", res)
    except Exception as e:
        import traceback
        traceback.print_exc()

asyncio.run(run())
