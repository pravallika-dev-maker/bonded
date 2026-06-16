import asyncio
import os
import sys

sys.path.append("C:\\Users\\prava\\OneDrive\\Desktop\\bonding\\backend")

from app.database import SessionLocal
from app.models.separation import Separation

db = SessionLocal()
seps = db.query(Separation).order_by(Separation.id.desc()).limit(5).all()

for sep in seps:
    print(f"ID: {sep.id}, status: {sep.status}, start: {sep.start_date}, ended_at: {sep.ended_at}")

db.close()
