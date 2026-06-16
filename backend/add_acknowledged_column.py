import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")
if not SQLALCHEMY_DATABASE_URL:
    SQLALCHEMY_DATABASE_URL = "sqlite:///./bonded.db"

engine = create_engine(SQLALCHEMY_DATABASE_URL)

def add_columns():
    try:
        with engine.connect() as conn:
            print("Adding has_acknowledged_completion to users...")
            conn.execute(text("ALTER TABLE users ADD COLUMN has_acknowledged_completion BOOLEAN DEFAULT FALSE;"))
            conn.commit()
            print("Successfully added has_acknowledged_completion column.")
    except Exception as e:
        print(f"Skipping has_acknowledged_completion (maybe already exists): {e}")

if __name__ == "__main__":
    add_columns()
