"""
Migration: Add last_active_at column to users table for shared presence detection.
Run once: python add_last_active_at_column.py
"""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database import engine
from sqlalchemy import text

def run():
    with engine.connect() as conn:
        try:
            conn.execute(text(
                "ALTER TABLE users ADD COLUMN last_active_at TIMESTAMP WITHOUT TIME ZONE"
            ))
            conn.commit()
            print("✅ Column 'last_active_at' added to users table.")
        except Exception as e:
            if "already exists" in str(e).lower() or "duplicate column" in str(e).lower():
                print("ℹ️  Column 'last_active_at' already exists — skipping.")
            else:
                raise

if __name__ == "__main__":
    run()
