import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.user import User
from app.models.relationship import Relationship
from app.models.letter import Letter
from app.models.separation import Separation

def migrate_data():
    db: Session = SessionLocal()
    try:
        # Find all pairs of connected users
        # To avoid duplicates, we can look for users where user.id < user.partner_id
        users_with_partners = db.query(User).filter(
            User.is_partnered == True, 
            User.partner_id.isnot(None),
            User.id < User.partner_id
        ).all()
        
        print(f"Found {len(users_with_partners)} relationship pairs to migrate.")
        
        for u1 in users_with_partners:
            u2 = db.query(User).filter(User.id == u1.partner_id).first()
            if not u2 or u2.partner_id != u1.id:
                print(f"Skipping user {u1.id} - asymmetric partnership")
                continue
                
            # Create a Relationship for them
            rel = Relationship(
                user1_id=u1.id,
                user2_id=u2.id,
                status="active",
                journey_score=u1.relationship_score or 0
            )
            db.add(rel)
            db.commit()
            db.refresh(rel)
            print(f"Created Relationship ID {rel.id} for users {u1.id} & {u2.id}")
            
            # Now update their Letters and Separations to point to this relationship
            
            # Letters
            letters = db.query(Letter).filter(
                ((Letter.author_id == u1.id) & (Letter.partner_id == u2.id)) |
                ((Letter.author_id == u2.id) & (Letter.partner_id == u1.id))
            ).all()
            
            for l in letters:
                l.relationship_id = rel.id
                
            # Separations
            separations = db.query(Separation).filter(
                ((Separation.creator_id == u1.id) & (Separation.partner_id == u2.id)) |
                ((Separation.creator_id == u2.id) & (Separation.partner_id == u1.id))
            ).all()
            
            for s in separations:
                s.relationship_id = rel.id
                
            db.commit()
            print(f"  -> Migrated {len(letters)} letters and {len(separations)} separations.")
            
        print("Data migration complete.")
    except Exception as e:
        print(f"Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    migrate_data()
