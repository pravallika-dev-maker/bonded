import sys
import os

# Add backend dir to path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.database import SessionLocal
from app.models.user import User
from app.models.relationship import Relationship
from app.models.separation import Separation

def delete_user_relationships(phone_number: str):
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.phone_number == phone_number).first()
        if not user:
            print(f"User with phone number {phone_number} not found.")
            return

        print(f"Found user {user.user_name} (ID: {user.id})")

        # Find relationships where the user is either user1 or user2
        relationships = db.query(Relationship).filter(
            (Relationship.user1_id == user.id) | (Relationship.user2_id == user.id)
        ).all()

        print(f"Found {len(relationships)} relationships to delete.")

        for rel in relationships:
            # Identify the partner's ID
            partner_id = rel.user2_id if rel.user1_id == user.id else rel.user1_id
            
            # Find the partner and unlink them
            partner = db.query(User).filter(User.id == partner_id).first()
            if partner and partner.partner_id == user.id:
                partner.is_partnered = False
                partner.partner_id = None
                partner.partner_name = None
                print(f"Unlinked partner {partner.user_name} (ID: {partner.id})")

            # Delete the relationship (cascades will handle separations, or we delete explicitly)
            separations = db.query(Separation).filter(Separation.relationship_id == rel.id).all()
            for sep in separations:
                db.delete(sep)
                
            db.delete(rel)

        # Unlink the current user
        user.is_partnered = False
        user.partner_id = None
        user.partner_name = None

        db.commit()
        print(f"Successfully deleted {len(relationships)} relationships and unlinked the user.")
    except Exception as e:
        print(f"Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    import sys
    # Use command line argument if provided, else default to the hardcoded one
    phone = sys.argv[1] if len(sys.argv) > 1 else "7569561617"
    delete_user_relationships(phone)
