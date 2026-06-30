from pydantic import BaseModel, ConfigDict
from typing import List, Optional
from datetime import datetime

# --- ASSETS ---
class SkyHavenAssetBase(BaseModel):
    id: str
    category: str
    asset_key: str
    display_name: str
    unlock_level: int
    rarity: str
    is_active: bool

class SkyHavenAssetListResponse(BaseModel):
    assets: List[SkyHavenAssetBase]


# --- REACTIONS ---
class SkyHavenReactionBase(BaseModel):
    id: str
    object_id: str
    reacted_by_user_id: int
    reaction: str
    created_at: datetime


# --- PLACED OBJECTS ---
class PlacedIslandObjectBase(BaseModel):
    id: str
    island_id: str
    asset_id: str
    placed_by_user_id: int
    position_x: float
    position_y: float
    rotation: float
    scale: float
    z_index: int
    whisper: Optional[str] = None
    has_unread_whisper: bool
    created_at: datetime
    reactions: List[SkyHavenReactionBase] = []


# --- MILESTONES ---
class SkyHavenMilestoneBase(BaseModel):
    id: str
    milestone_type: str
    unlocked_at: datetime


# --- ISLAND ---
class SkyHavenIslandStatus(BaseModel):
    island_version: int
    current_turn_user_id: int
    updated_at: datetime

class SkyHavenIslandResponse(BaseModel):
    id: str
    couple_id: int
    current_turn_user_id: int
    expansion_stage: int
    island_version: int
    created_at: datetime
    updated_at: datetime
    objects: List[PlacedIslandObjectBase] = []
    milestones: List[SkyHavenMilestoneBase] = []


# --- REQUEST SCHEMAS ---
class PlaceObjectRequest(BaseModel):
    asset_id: str
    position_x: float
    position_y: float
    rotation: float = 0.0
    scale: float = 1.0
    optional_whisper: Optional[str] = None

class ReactObjectRequest(BaseModel):
    reaction: str
