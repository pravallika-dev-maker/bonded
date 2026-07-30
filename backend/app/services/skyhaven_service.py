from sqlalchemy.orm import Session
from fastapi import HTTPException
from datetime import datetime, timezone
from ..models.sky_haven import SkyHavenIsland, SkyHavenAsset, PlacedIslandObject, SkyHavenReaction, SkyHavenMilestone
from ..models.relationship import Relationship
from ..schemas.sky_haven import PlaceObjectRequest, ReactObjectRequest
import uuid

def get_or_create_island(db: Session, couple_id: int, user_id: int) -> SkyHavenIsland:
    island = db.query(SkyHavenIsland).filter(SkyHavenIsland.couple_id == couple_id).first()
    if not island:
        # Create a new island. The first turn goes to the user who triggers this.
        island = SkyHavenIsland(
            couple_id=couple_id,
            current_turn_user_id=user_id,
        )
        db.add(island)
        db.commit()
        db.refresh(island)
    return island

def get_island_full(db: Session, couple_id: int, user_id: int):
    island = get_or_create_island(db, couple_id, user_id)
    objects = db.query(PlacedIslandObject).filter(PlacedIslandObject.island_id == island.id).all()
    milestones = db.query(SkyHavenMilestone).filter(SkyHavenMilestone.island_id == island.id).all()
    
    # Eagerly load reactions? We can query them manually.
    for obj in objects:
        obj.reactions = db.query(SkyHavenReaction).filter(SkyHavenReaction.object_id == obj.id).all()
        
    return {
        "id": island.id,
        "couple_id": island.couple_id,
        "current_turn_user_id": island.current_turn_user_id,
        "expansion_stage": island.expansion_stage,
        "island_version": island.island_version,
        "created_at": island.created_at,
        "updated_at": island.updated_at,
        "objects": objects,
        "milestones": milestones
    }

def get_island_status(db: Session, couple_id: int, user_id: int):
    island = get_or_create_island(db, couple_id, user_id)
    return {
        "island_version": island.island_version,
        "current_turn_user_id": island.current_turn_user_id,
        "updated_at": island.updated_at
    }

def get_assets(db: Session):
    return db.query(SkyHavenAsset).filter(SkyHavenAsset.is_active == True).all()

def get_partner_id(db: Session, couple_id: int, user_id: int) -> int:
    relationship = db.query(Relationship).filter(Relationship.id == couple_id).first()
    if not relationship:
        raise HTTPException(status_code=404, detail="Relationship not found")
    if relationship.user1_id == user_id:
        return relationship.user2_id
    elif relationship.user2_id == user_id:
        return relationship.user1_id
    else:
        raise HTTPException(status_code=403, detail="User not part of this relationship")

def place_object(db: Session, couple_id: int, user_id: int, data: PlaceObjectRequest):
    island = db.query(SkyHavenIsland).filter(SkyHavenIsland.couple_id == couple_id).first()
    if not island:
        raise HTTPException(status_code=404, detail="Island not found")
        
    if island.current_turn_user_id != user_id:
        raise HTTPException(status_code=400, detail="Not your turn")
        
    asset = db.query(SkyHavenAsset).filter(SkyHavenAsset.id == data.asset_id).first()
    if not asset:
        raise HTTPException(status_code=404, detail="Asset not found")
        
    new_object = PlacedIslandObject(
        island_id=island.id,
        asset_id=asset.id,
        placed_by_user_id=user_id,
        position_x=data.position_x,
        position_y=data.position_y,
        rotation=data.rotation,
        scale=data.scale,
        whisper=data.optional_whisper,
        has_unread_whisper=bool(data.optional_whisper)
    )
    db.add(new_object)
    
    # Switch turns
    partner_id = get_partner_id(db, couple_id, user_id)
    island.current_turn_user_id = partner_id
    island.island_version += 1
    island.updated_at = datetime.now(timezone.utc)
    
    # Basic logic for island expansion based on object count
    object_count = db.query(PlacedIslandObject).filter(PlacedIslandObject.island_id == island.id).count() + 1
    if object_count > 10 and island.expansion_stage < 2:
        island.expansion_stage = 2
        # Unlock milestone
        ms = SkyHavenMilestone(island_id=island.id, milestone_type="LAND_EXPANSION")
        db.add(ms)
        
    db.commit()
    db.refresh(new_object)
    return new_object

def read_whisper(db: Session, couple_id: int, user_id: int, object_id: str):
    obj = db.query(PlacedIslandObject).filter(PlacedIslandObject.id == object_id).first()
    if not obj:
        raise HTTPException(status_code=404, detail="Object not found")
        
    # Check if user belongs to couple is implicitly handled by island ownership
    island = db.query(SkyHavenIsland).filter(SkyHavenIsland.id == obj.island_id).first()
    if not island or island.couple_id != couple_id:
        raise HTTPException(status_code=403, detail="Not your island")
        
    obj.has_unread_whisper = False
    island.island_version += 1
    island.updated_at = datetime.now(timezone.utc)
    
    db.commit()
    return {"status": "success"}

def react_object(db: Session, couple_id: int, user_id: int, object_id: str, data: ReactObjectRequest):
    obj = db.query(PlacedIslandObject).filter(PlacedIslandObject.id == object_id).first()
    if not obj:
        raise HTTPException(status_code=404, detail="Object not found")
        
    island = db.query(SkyHavenIsland).filter(SkyHavenIsland.id == obj.island_id).first()
    if not island or island.couple_id != couple_id:
        raise HTTPException(status_code=403, detail="Not your island")
        
    reaction = SkyHavenReaction(
        object_id=obj.id,
        reacted_by_user_id=user_id,
        reaction=data.reaction
    )
    db.add(reaction)
    
    island.island_version += 1
    island.updated_at = datetime.now(timezone.utc)
    
    db.commit()
    return reaction
