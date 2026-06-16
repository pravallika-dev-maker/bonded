"""
One-time migration: create the user_daily_comforts table.
Run with: python create_comfort_table.py
"""
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

# Import ALL models so SQLAlchemy can resolve foreign key references (e.g. users table)
from app.database import Base, engine
from app.models.user import User  # noqa
from app.models.relationship import Relationship  # noqa
from app.models.separation import Separation  # noqa
from app.models.mood import Mood  # noqa
from app.models.letter import Letter  # noqa
from app.models.user_daily_affirmation import UserDailyAffirmation  # noqa
from app.models.user_daily_insight import UserDailyInsight  # noqa
from app.models.user_daily_comfort import UserDailyComfort  # noqa — the new table

def main():
    print("Creating user_daily_comforts table if it doesn't exist...")
    # create_all is idempotent — safe to run multiple times
    Base.metadata.create_all(bind=engine)
    print("Done. Table 'user_daily_comforts' is ready.")

if __name__ == "__main__":
    main()
