import os
import sys

sys.path.insert(0, r"c:\Users\prava\OneDrive\Desktop\bonding\backend")
from sqlalchemy import create_engine, inspect, text
from app.database import Base
from app.models import *

def count_rows(engine, db_name):
    print(f"\n--- Row Counts for {db_name} ---")
    try:
        with engine.connect() as conn:
            inspector = inspect(engine)
            tables = inspector.get_table_names()
            if not tables:
                print("No tables found.")
                return
            for table in tables:
                try:
                    count = conn.execute(text(f'SELECT COUNT(*) FROM "{table}"')).scalar()
                    print(f"{table}: {count} rows")
                except Exception as e:
                    print(f"{table}: ERROR ({e})")
    except Exception as e:
        print(f"Failed to connect to {db_name}: {e}")

# 1. Check RDS Database
rds_url = "postgresql://vrikshaappuser:KNU_%3AYX%3AH68H~G!@localhost:5433/bonded"
rds_engine = create_engine(rds_url)
count_rows(rds_engine, "RDS Database (EC2)")

# 2. Check local SQLite Database
sqlite_url = "sqlite:///./bonded.db"
sqlite_engine = create_engine(sqlite_url)
count_rows(sqlite_engine, "Local SQLite Database (bonded.db)")

# 3. Check Render Database (from .env)
from dotenv import load_dotenv
load_dotenv()
render_url = os.getenv("DATABASE_URL")
if render_url:
    render_engine = create_engine(render_url)
    count_rows(render_engine, "Render Database (.env DATABASE_URL)")
