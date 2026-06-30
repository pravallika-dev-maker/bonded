from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey
from datetime import datetime, timezone
import uuid
from ..database import Base

def generate_uuid():
    return str(uuid.uuid4())

class SkyHavenIsland(Base):
    __tablename__ = "sky_haven_islands"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    couple_id = Column(Integer, ForeignKey("relationships.id"), index=True) # Assuming relationship ID links the couple
    current_turn_user_id = Column(Integer, ForeignKey("users.id"))
    expansion_stage = Column(Integer, default=1)
    island_version = Column(Integer, default=1)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

class SkyHavenAsset(Base):
    __tablename__ = "sky_haven_assets"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    category = Column(String, index=True) # Nature, Water, Cozy, Lights, Living, Wonder
    asset_key = Column(String, unique=True, index=True)
    display_name = Column(String)
    unlock_level = Column(Integer, default=1)
    rarity = Column(String, default="Common")
    is_active = Column(Boolean, default=True)

class PlacedIslandObject(Base):
    __tablename__ = "placed_island_objects"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    island_id = Column(String, ForeignKey("sky_haven_islands.id"), index=True)
    asset_id = Column(String, ForeignKey("sky_haven_assets.id"))
    placed_by_user_id = Column(Integer, ForeignKey("users.id"))
    
    position_x = Column(Float, nullable=False)
    position_y = Column(Float, nullable=False)
    rotation = Column(Float, default=0.0)
    scale = Column(Float, default=1.0)
    z_index = Column(Integer, default=0)
    
    whisper = Column(String, nullable=True)
    has_unread_whisper = Column(Boolean, default=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

class SkyHavenReaction(Base):
    __tablename__ = "sky_haven_reactions"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    object_id = Column(String, ForeignKey("placed_island_objects.id"), index=True)
    reacted_by_user_id = Column(Integer, ForeignKey("users.id"))
    reaction = Column(String)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

class SkyHavenMilestone(Base):
    __tablename__ = "sky_haven_milestones"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    island_id = Column(String, ForeignKey("sky_haven_islands.id"), index=True)
    milestone_type = Column(String, index=True)
    unlocked_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
