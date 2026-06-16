"""
Run this script ONCE to add the missing ai_love_score column
to the existing letters table on your Render database.

Steps:
1. Temporarily set DATABASE_URL in .env to your Render External DB URL
2. Run: venv\Scripts\python.exe add_letter_columns.py
3. Set DATABASE_URL back to your local DB URL
"""
import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(DATABASE_URL)

with engine.connect() as conn:
    try:
        # Add ai_love_score column to letters table if it doesn't exist
        conn.execute(text("""
            ALTER TABLE letters
            ADD COLUMN IF NOT EXISTS ai_love_score INTEGER DEFAULT 0;
        """))
        # Add relationship_score column to users table if it doesn't exist
        conn.execute(text("""
            ALTER TABLE users
            ADD COLUMN IF NOT EXISTS relationship_score INTEGER DEFAULT 0;
        """))
        conn.commit()
        print("✅ SUCCESS: Database tables migrated successfully!")
    except Exception as e:
        print(f"❌ Error: {e}")
