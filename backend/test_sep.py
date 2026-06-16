import asyncio
import os
import sys

# Add the project directory to sys.path
sys.path.append("C:\\Users\\prava\\OneDrive\\Desktop\\bonding\\backend")

from app.database import SessionLocal
from app.models.user import User
from app.models.separation import Separation

db = SessionLocal()
# find a completed separation
sep = db.query(Separation).filter(Separation.status == "completed").order_by(Separation.ended_at.desc()).first()

if sep:
    print(f"Found completed separation ID: {sep.id}, creator: {sep.creator_id}, partner: {sep.partner_id}")
    print(f"Start: {sep.start_date}, End: {sep.ended_at}, Expected: {sep.expected_end_date}")
    print(f"Closing Insight: {sep.closing_insight}")
else:
    print("No completed separation found.")

db.close()
