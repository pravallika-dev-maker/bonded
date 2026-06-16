"""
One-time script to create the daily_affirmations table directly.
Used because the Alembic migration was stamped before DDL was added to it.
"""
from app.database import engine, Base
from app.models import daily_affirmation  # noqa: F401 - register the model

# Create only tables that don't exist yet (checkfirst=True)
Base.metadata.create_all(bind=engine, checkfirst=True)
print("✅ daily_affirmations table created successfully.")
