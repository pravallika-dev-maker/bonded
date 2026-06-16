from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date
from ...database import get_db
from ..deps import get_current_user, get_active_relationship
from ...models.user import User
from ...models.letter import Letter
from ...models.separation import Separation
from ...schemas.letter import LetterCreate, LetterUpdate, LetterResponse, PartnerLetterScreenResponse
from ...services.ai_service import evaluate_love_letter
from ...services.notification_service import create_notification_and_push


router = APIRouter(prefix="/letters", tags=["Letters"])


def map_letter_to_screen(letter: Letter, start_date) -> Optional[int]:
    """
    Maps a letter to one of the 4 screens based on letter type, content keywords,
    day written, or score range.
    """
    l_type = (letter.letter_type or "").lower()
    score = letter.ai_love_score or 0
    content = letter.content.lower()

    # Safety Shield: Reject blaming/toxic letters
    if score < 40:
        return None

    # 1. Match by Explicit Keywords / Sentiment Categories
    # Screen 2: What hurt them 💔
    if "hurt" in l_type or "sad" in l_type or "fear" in l_type or any(w in content for w in ["hurt", "pain", "sad", "fear", "scared", "afraid"]):
        if 40 <= score <= 85:
            return 2

    # Screen 1: When they missed you 💭
    if "miss" in l_type or "longing" in l_type or any(w in content for w in ["miss", "longing", "ache", "empty"]):
        if score >= 60:
            return 1

    # Screen 4: What they want to change for you
    if any(t in l_type for t in ["change", "growth", "future", "hope"]) or any(w in content for w in ["change", "grow", "future", "improve", "different"]):
        if score >= 80:
            return 4

    # Screen 3: What they love about you ❤️
    if "love" in l_type or "appreciation" in l_type or "grateful" in l_type or any(w in content for w in ["love", "appreciate", "thank", "grateful", "warm"]):
        if score >= 80:
            return 3

    # 2. Fallback 1: Match by Day written of separation
    if start_date:
        day_written = (letter.created_at.date() - start_date).days + 1
        if day_written == 3:
            return 1
        elif day_written == 4:
            return 2
        elif day_written == 5:
            return 3
        elif day_written == 6:
            return 4

    # 3. Fallback 2: Match by Score ranges
    if 40 <= score <= 75:
        return 2  # Hurt / expression of pain (constructive medium range)
    elif 76 <= score <= 85:
        return 1  # Longing / missing (warm medium-to-high range)
    elif 86 <= score <= 93:
        return 3  # Love / appreciation (high range)
    else:  # score >= 94
        return 4  # Deep commitment / change / future (highest range)


@router.post("/", response_model=LetterResponse)
async def create_letter(
    letter_data: LetterCreate, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user),
    active_rel = Depends(get_active_relationship)
):
    # Guard: letters can only be written during an active separation
    if not active_rel:
        raise HTTPException(
            status_code=400,
            detail="You must have an active partner connection to write letters."
        )

    active_sep = db.query(Separation).filter(
        (Separation.creator_id == current_user.id) | (Separation.partner_id == current_user.id),
        Separation.relationship_id == active_rel.id,
        Separation.status == "active"
    ).order_by(Separation.created_at.desc()).first()
    if not active_sep:
        raise HTTPException(
            status_code=400,
            detail="Letters can only be written during an active separation period."
        )

    # Ask Gemini to score how loving/forgiving the letter is (0-100)
    ai_score = await evaluate_love_letter(letter_data.content)

    new_letter = Letter(
        author_id=current_user.id,
        partner_id=current_user.partner_id,
        relationship_id=active_rel.id if active_rel else None,
        title=letter_data.title,
        content=letter_data.content,
        letter_type=letter_data.letter_type.lower() if letter_data.letter_type else None,
        ai_love_score=ai_score
    )
    db.add(new_letter)
    db.commit()
    db.refresh(new_letter)



    return new_letter


@router.get("/", response_model=List[LetterResponse])
def get_user_letters(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    active_rel = Depends(get_active_relationship)
):
    """
    Returns all letters authored by the current user for the active relationship.
    If no active relationship exists, returns an empty list.
    """
    if not active_rel:
        return []

    letters = db.query(Letter).filter(
        Letter.author_id == current_user.id,
        Letter.relationship_id == active_rel.id
    ).order_by(Letter.created_at.desc()).all()
    return letters





@router.patch("/{letter_id}", response_model=LetterResponse)
async def update_letter(
    letter_id: int,
    update_data: LetterUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Edit a letter's title and/or content.
    If content is changed, Gemini re-evaluates the AI love score.
    Only the author can edit their own letter.
    """
    letter = db.query(Letter).filter(
        Letter.id == letter_id,
        Letter.author_id == current_user.id
    ).first()
    if not letter:
        raise HTTPException(status_code=404, detail="Letter not found")

    if update_data.title is not None:
        letter.title = update_data.title

    if update_data.content is not None:
        letter.content = update_data.content
        # Re-score with Gemini since content changed
        letter.ai_love_score = await evaluate_love_letter(update_data.content)

    db.commit()
    db.refresh(letter)
    return letter


@router.delete("/{letter_id}")
def delete_letter(
    letter_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Permanently deletes a letter. Only the author can delete their own letter."""
    letter = db.query(Letter).filter(
        Letter.id == letter_id,
        Letter.author_id == current_user.id
    ).first()
    if not letter:
        raise HTTPException(status_code=404, detail="Letter not found")

    db.delete(letter)
    db.commit()
    return {"success": True, "message": "Letter deleted successfully"}
