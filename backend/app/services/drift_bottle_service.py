import random
from datetime import datetime, timezone
from sqlalchemy.orm import Session
from sqlalchemy import desc

from app.models.drift_bottle import DriftBottleHistory, UserReward
from app.schemas.drift_bottle import DriftBottleStatusResponse, UserRewardsResponse, DriftBottleOpenResponse

def get_drift_bottle_status(db: Session, user_id: int) -> DriftBottleStatusResponse:
    last_opened = db.query(DriftBottleHistory).filter(
        DriftBottleHistory.user_id == user_id
    ).order_by(desc(DriftBottleHistory.opened_at)).first()

    now = datetime.now(timezone.utc)
    can_open = True
    
    if last_opened and last_opened.opened_at:
        # Check if the last opened date is today
        # assuming opened_at is stored as UTC datetime
        # local timezone logic might be needed if "day" is based on user's local time
        # For now, using UTC calendar day.
        if last_opened.opened_at.date() == now.date():
            can_open = False
            
    return DriftBottleStatusResponse(
        can_open=can_open,
        last_opened=last_opened.opened_at if last_opened else None
    )

def get_user_rewards(db: Session, user_id: int) -> UserRewardsResponse:
    rewards = db.query(UserReward).filter(UserReward.user_id == user_id).first()
    if not rewards:
        return UserRewardsResponse(love_tokens=0, aura_fragments=0)
    
    return UserRewardsResponse(
        love_tokens=rewards.love_tokens,
        aura_fragments=rewards.aura_fragments
    )

def open_drift_bottle(db: Session, user_id: int) -> DriftBottleOpenResponse:
    # 1. Check if user already opened today
    status = get_drift_bottle_status(db, user_id)
    if not status.can_open:
        return DriftBottleOpenResponse(
            success=False,
            message="Bottle already opened today"
        )
    
    # 2. Generate reward using probability rules
    # 50% for 1 token, 30% for 2 tokens, 15% for 3 tokens, 5% for 1 aura fragment
    roll = random.random() # 0.0 to 1.0
    
    reward_type = "love_token"
    reward_value = 1
    
    if roll < 0.50:
        reward_type = "love_token"
        reward_value = 1
    elif roll < 0.80:
        reward_type = "love_token"
        reward_value = 2
    elif roll < 0.95:
        reward_type = "love_token"
        reward_value = 3
    else:
        reward_type = "aura_fragment"
        reward_value = 1
        
    # 3. Update or create UserReward
    user_reward = db.query(UserReward).filter(UserReward.user_id == user_id).first()
    if not user_reward:
        user_reward = UserReward(user_id=user_id, love_tokens=0, aura_fragments=0)
        db.add(user_reward)
        db.commit()
        db.refresh(user_reward)
        
    if reward_type == "love_token":
        user_reward.love_tokens += reward_value
    elif reward_type == "aura_fragment":
        user_reward.aura_fragments += reward_value
        
    # 4. Insert into drift_bottle_history
    history_entry = DriftBottleHistory(
        user_id=user_id,
        reward_type=reward_type,
        reward_value=reward_value,
        opened_at=datetime.now(timezone.utc)
    )
    db.add(history_entry)
    db.commit()
    
    db.refresh(user_reward)
    
    return DriftBottleOpenResponse(
        success=True,
        reward_type=reward_type,
        reward_value=reward_value,
        total_love_tokens=user_reward.love_tokens,
        total_aura_fragments=user_reward.aura_fragments
    )
