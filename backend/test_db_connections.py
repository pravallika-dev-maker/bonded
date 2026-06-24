import os
from sqlalchemy import create_engine
from dotenv import load_dotenv

load_dotenv()

old_url = os.environ.get("DATABASE_URL")
new_url = "postgresql://postgres:KNU_:YX:H68H~G!@vrikshaappuser/bonded"

print(f"Testing OLD database: {old_url}")
try:
    engine1 = create_engine(old_url, connect_args={'connect_timeout': 5})
    with engine1.connect() as conn:
        print("SUCCESS: Connected to OLD database!")
except Exception as e:
    print(f"FAIL: Could not connect to OLD database: {e}")

print(f"\nTesting NEW database: {new_url}")
try:
    engine2 = create_engine(new_url, connect_args={'connect_timeout': 5})
    with engine2.connect() as conn:
        print("SUCCESS: Connected to NEW database!")
except Exception as e:
    print(f"FAIL: Could not connect to NEW database: {e}")
