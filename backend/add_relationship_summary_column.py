import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")
if not SQLALCHEMY_DATABASE_URL:
    raise RuntimeError("DATABASE_URL environment variable is not set.")

engine = create_engine(SQLALCHEMY_DATABASE_URL)

def add_columns():
    with engine.connect() as conn:
        print("Adding summary_insight column to relationships table...")
        conn.execute(text("ALTER TABLE relationships ADD COLUMN IF NOT EXISTS summary_insight TEXT;"))
        print("Adding relationship_type column to relationships table...")
        conn.execute(text("ALTER TABLE relationships ADD COLUMN IF NOT EXISTS relationship_type VARCHAR(50);"))
        print("Adding user1_name column to relationships table...")
        conn.execute(text("ALTER TABLE relationships ADD COLUMN IF NOT EXISTS user1_name VARCHAR(100);"))
        print("Adding user2_name column to relationships table...")
        conn.execute(text("ALTER TABLE relationships ADD COLUMN IF NOT EXISTS user2_name VARCHAR(100);"))
        conn.commit()
        print("Successfully updated the relationships table schema.")

if __name__ == "__main__":
    add_columns()
