from app.database import engine, Base
from app.models import user, poke

print("Creating pokes table...")
Base.metadata.create_all(bind=engine)
print("pokes table created successfully.")
