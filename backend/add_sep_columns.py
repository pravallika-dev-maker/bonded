import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:postgre@localhost:5432/bonded_db")
engine = create_engine(SQLALCHEMY_DATABASE_URL)

def add_columns():
    with engine.connect() as conn:
        print("Adding expected_end_date...")
        conn.execute(text("ALTER TABLE separations ADD COLUMN IF NOT EXISTS expected_end_date DATE;"))
        conn.commit()
        print("Successfully updated the separations table schema.")

if __name__ == "__main__":
    add_columns()
