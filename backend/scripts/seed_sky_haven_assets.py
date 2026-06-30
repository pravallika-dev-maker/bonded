import os
import sys
from dotenv import load_dotenv
from sqlalchemy.orm import Session

# Add parent dir to path so we can import app modules
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

load_dotenv()

from app.database import SessionLocal, engine
from app.models.sky_haven import SkyHavenAsset, Base
from sqlalchemy import select

ASSETS = [
    # Nature
    {"category": "Nature", "asset_key": "sakura_tree", "display_name": "Sakura Tree", "unlock_level": 1, "rarity": "Common"},
    {"category": "Nature", "asset_key": "weeping_willow", "display_name": "Weeping Willow", "unlock_level": 2, "rarity": "Uncommon"},
    {"category": "Nature", "asset_key": "moonflower_bush", "display_name": "Moonflower Bush", "unlock_level": 1, "rarity": "Common"},
    
    # Water
    {"category": "Water", "asset_key": "koi_pond", "display_name": "Tranquil Koi Pond", "unlock_level": 1, "rarity": "Rare"},
    {"category": "Water", "asset_key": "waterfall_edge", "display_name": "Edge Waterfall", "unlock_level": 3, "rarity": "Epic"},
    
    # Cozy
    {"category": "Cozy", "asset_key": "picnic_blanket", "display_name": "Picnic Blanket", "unlock_level": 1, "rarity": "Common"},
    {"category": "Cozy", "asset_key": "swing_bench", "display_name": "Swing Bench", "unlock_level": 2, "rarity": "Uncommon"},
    
    # Lights
    {"category": "Lights", "asset_key": "paper_lantern", "display_name": "Paper Lantern", "unlock_level": 1, "rarity": "Common"},
    {"category": "Lights", "asset_key": "fairy_lights", "display_name": "Fairy Lights", "unlock_level": 2, "rarity": "Uncommon"},
    {"category": "Lights", "asset_key": "glowing_mushrooms", "display_name": "Glowing Mushrooms", "unlock_level": 3, "rarity": "Rare"},
    
    # Living
    {"category": "Living", "asset_key": "sleeping_fox", "display_name": "Sleeping Fox", "unlock_level": 4, "rarity": "Epic"},
    {"category": "Living", "asset_key": "butterflies", "display_name": "Blue Butterflies", "unlock_level": 2, "rarity": "Rare"},
    
    # Wonder
    {"category": "Wonder", "asset_key": "star_fragment", "display_name": "Fallen Star Fragment", "unlock_level": 5, "rarity": "Legendary"},
]

def seed_assets(db: Session):
    print("Seeding Sky Haven assets...")
    added = 0
    for asset_data in ASSETS:
        existing = db.execute(
            select(SkyHavenAsset).where(SkyHavenAsset.asset_key == asset_data["asset_key"])
        ).scalar_one_or_none()
        
        if not existing:
            new_asset = SkyHavenAsset(
                category=asset_data["category"],
                asset_key=asset_data["asset_key"],
                display_name=asset_data["display_name"],
                unlock_level=asset_data["unlock_level"],
                rarity=asset_data["rarity"],
                is_active=True
            )
            db.add(new_asset)
            added += 1
            print(f"Added {asset_data['asset_key']}")
    
    db.commit()
    print(f"Seeding complete! Added {added} new assets.")

if __name__ == "__main__":
    db = SessionLocal()
    try:
        seed_assets(db)
    except Exception as e:
        print(f"Error seeding assets: {e}")
    finally:
        db.close()
