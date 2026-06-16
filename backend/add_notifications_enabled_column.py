import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")
if not SQLALCHEMY_DATABASE_URL:
    SQLALCHEMY_DATABASE_URL = "postgresql://postgres:postgre@localhost:5432/bonded_db"

engine = create_engine(SQLALCHEMY_DATABASE_URL)

def add_columns():
    with engine.connect() as conn:
        print("Adding notifications_enabled...")
        conn.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS notifications_enabled BOOLEAN DEFAULT TRUE;"))
        conn.commit()
        print("Successfully updated the users table schema.")

if __name__ == "__main__":
    add_columns()
