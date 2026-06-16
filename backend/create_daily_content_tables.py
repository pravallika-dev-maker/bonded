import sys
from sqlalchemy import text
from app.database import engine, Base
from app.models import user, user_daily_affirmation, user_daily_insight

print("Creating new tables...")
Base.metadata.create_all(bind=engine)
print("Tables created.")

print("Dropping old table daily_affirmations...")
try:
    with engine.begin() as conn:
        conn.execute(text("DROP TABLE IF EXISTS daily_affirmations CASCADE"))
    print("Old table dropped successfully.")
except Exception as e:
    print("Error dropping table:", e)
