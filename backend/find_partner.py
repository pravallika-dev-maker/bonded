import asyncio
from app.database import SessionLocal
from app.models.user import User

def get_partner():
    db = SessionLocal()
    try:
        # 1. Find user by phone number
        user = db.query(User).filter(User.phone_number == "7569561617").first()
        if not user:
            print("User with phone 7569561617 not found.")
            return
            
        print(f"User found: {user.user_name} (ID: {user.id})")
        
        # 2. Check if they have a partner
        if not user.partner_id:
            print(f"User {user.user_name} does NOT have a partner linked yet.")
            return
            
        # 3. Find partner details
        partner = db.query(User).filter(User.id == user.partner_id).first()
        if partner:
            print(f"\n--- PARTNER DETAILS ---")
            print(f"Name: {partner.user_name}")
            print(f"Phone: {partner.country_code} {partner.phone_number}")
            print(f"Gender: {partner.gender}")
            print(f"Partner ID: {partner.id}")
        else:
            print(f"Partner ID {user.partner_id} found, but partner user record is missing!")
            
    finally:
        db.close()

if __name__ == "__main__":
    get_partner()
