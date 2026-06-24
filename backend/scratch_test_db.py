import os
import sys

sys.path.insert(0, r"c:\Users\prava\OneDrive\Desktop\bonding\backend")

from sqlalchemy import create_engine, inspect, text
from app.database import Base
from app.models import user, mood, invite_code, separation, notification, question_category, reflection_question, reflection_session, reflection_answer, reflection_comparison, letter, user_daily_affirmation, user_daily_insight, user_daily_comfort, relationship

db_url = "postgresql://vrikshaappuser:KNU_%3AYX%3AH68H~G!@localhost:5433/bonded"
engine = create_engine(db_url)

try:
    with engine.connect() as conn:
        print("SUCCESS: Connected to the database.")
        
        inspector = inspect(engine)
        tables = inspector.get_table_names()
        
        expected_tables = Base.metadata.tables.keys()
        missing = set(expected_tables) - set(tables)
        
        if missing:
            print(f"Creating missing tables: {missing}")
            Base.metadata.create_all(bind=engine)
            print("Missing tables created successfully!")
        else:
            print("All model tables exist in the DB!")
            
    # Run alembic stamp manually using pure SQL to avoid configparser % syntax bug
    with engine.begin() as conn:
        conn.execute(text("CREATE TABLE IF NOT EXISTS alembic_version (version_num VARCHAR(32) NOT NULL, CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num))"))
        conn.execute(text("DELETE FROM alembic_version"))
        conn.execute(text("INSERT INTO alembic_version (version_num) VALUES ('15b8895c9f85')"))
    
    print("Alembic stamped to head (15b8895c9f85) successfully via raw SQL.")
    
except Exception as e:
    print(f"Failed: {e}")
