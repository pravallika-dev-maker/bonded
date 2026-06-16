import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")
if not SQLALCHEMY_DATABASE_URL:
    SQLALCHEMY_DATABASE_URL = "sqlite:///./bonded.db"

engine = create_engine(SQLALCHEMY_DATABASE_URL)

def add_columns():
    # User table
    try:
        with engine.connect() as conn:
            print("Adding fcm_token to users...")
            conn.execute(text("ALTER TABLE users ADD COLUMN fcm_token VARCHAR;"))
            conn.commit()
            print("Successfully added fcm_token column.")
    except Exception as e:
        print(f"Skipping fcm_token (maybe already exists): {e}")
        
    # Notification table
    try:
        with engine.connect() as conn:
            print("Adding push_sent to notifications...")
            conn.execute(text("ALTER TABLE notifications ADD COLUMN push_sent BOOLEAN DEFAULT FALSE;"))
            conn.commit()
            print("Successfully added push_sent column.")
    except Exception as e:
        print(f"Skipping push_sent (maybe already exists): {e}")

if __name__ == "__main__":
    add_columns()
