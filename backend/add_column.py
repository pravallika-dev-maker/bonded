import os
from sqlalchemy import create_engine
from dotenv import load_dotenv

load_dotenv()
db_url = os.getenv("DATABASE_URL")
print("Connecting to", db_url)

try:
    engine = create_engine(db_url)
    with engine.begin() as conn:
        conn.exec_driver_sql("ALTER TABLE moods ADD COLUMN partner_name VARCHAR;")
    print("Column added successfully.")
except Exception as e:
    print("Error:", e)
