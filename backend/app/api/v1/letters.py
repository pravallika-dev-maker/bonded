from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date
from ...database import get_db
from ..deps import get_current_user
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
    current_user: User = Depends(get_current_user)
):
    # Ask Gemini to score how loving/forgiving the letter is (0-100)
    ai_score = await evaluate_love_letter(letter_data.content)

    new_letter = Letter(
        author_id=current_user.id,
        partner_id=current_user.partner_id,
        title=letter_data.title,
        content=letter_data.content,
        letter_type=letter_data.letter_type.lower() if letter_data.letter_type else None,
        ai_love_score=ai_score
    )
    db.add(new_letter)
    db.commit()
    db.refresh(new_letter)

    # Trigger 5: Partner writes a letter -> You get notified
    if current_user.partner_id:
        partner = db.query(User).filter(User.id == current_user.partner_id).first()
        if partner:
            partner_name = current_user.user_name or "Your partner"
            create_notification_and_push(
                db=db,
                recipient_id=partner.id,
                notification_type="letter_written",
                title="💌 A letter arrived",
                body=f"{partner_name} wrote you something. It reveals when the time is right.",
                fcm_token=partner.fcm_token
            )

    return new_letter



@router.get("/my", response_model=List[LetterResponse])
def get_my_letters(
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    """Returns all letters the current user has written."""
    return db.query(Letter).filter(Letter.author_id == current_user.id).order_by(Letter.created_at.desc()).all()


@router.get("/partner/revealed", response_model=List[PartnerLetterScreenResponse])
def get_revealed_partner_letters(
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    """
    Returns structured letters written by the partner for the 4 swipeable reveal screens.
    Triggered on the last day of the separation or later.
    """
    screens = [
        {"screen": 1, "day": 3, "prompt_title": "Day 3 – When they missed you 💭", "action_label": "Show message", "letter": None},
        {"screen": 2, "day": 4, "prompt_title": "Day 4 – What hurt them 💔", "action_label": "Show message", "letter": None},
        {"screen": 3, "day": 5, "prompt_title": "Day 5 – What they love about you ❤️", "action_label": "Show message", "letter": None},
        {"screen": 4, "day": 6, "prompt_title": "Day 6 – What they want to change for you.", "action_label": "Show message", "letter": None},
    ]

    if not current_user.partner_id:
        return screens

    # 1. Check for active or recently completed separation
    sep = db.query(Separation).filter(
        (Separation.creator_id == current_user.id) | (Separation.partner_id == current_user.id),
        Separation.status == "active"
    ).first()

    if not sep:
        sep = db.query(Separation).filter(
            (Separation.creator_id == current_user.id) | (Separation.partner_id == current_user.id),
            Separation.status == "completed"
        ).order_by(Separation.ended_at.desc()).first()

    if sep:
        # If the separation is active, check if it's the last day (expected_end_date reached/passed)
        if sep.status == "active":
            days_remaining = (sep.expected_end_date - date.today()).days
            
            # Reveal only on the final day (0 days remaining) or past it.
            if days_remaining <= 0:
                hidden_love_letters = db.query(Letter).filter(
                    Letter.author_id == current_user.partner_id,
                    Letter.ai_love_score >= 40,  # Safeguard: only letters that are not toxic/blaming (>=40)
                    Letter.is_revealed == False
                ).all()

                if hidden_love_letters:
                    for letter in hidden_love_letters:
                        letter.is_revealed = True
                    db.commit()
                    
                    create_notification_and_push(
                        db, 
                        recipient_id=current_user.id, 
                        notification_type="letters_revealed",
                        title="📖 Letters are now revealed",
                        body="There's something your partner couldn't say before.",
                        fcm_token=current_user.fcm_token
                    )


        # 2. Get all currently revealed letters from the partner
        revealed_letters = db.query(Letter).filter(
            Letter.author_id == current_user.partner_id,
            Letter.is_revealed == True
        ).order_by(Letter.created_at.desc()).all()

        # 3. Map letters to screens
        for letter in revealed_letters:
            screen_idx = map_letter_to_screen(letter, sep.start_date)
            if screen_idx is not None and 1 <= screen_idx <= 4:
                # If no letter mapped yet, or this one has a higher love score, map it
                existing = screens[screen_idx - 1]["letter"]
                if not existing or letter.ai_love_score > existing.ai_love_score:
                    screens[screen_idx - 1]["letter"] = letter

    return screens



@router.get("/{letter_id}", response_model=LetterResponse)
def get_letter(
    letter_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Returns a single letter by ID. Only the author can access it."""
    letter = db.query(Letter).filter(
        Letter.id == letter_id,
        Letter.author_id == current_user.id
    ).first()
    if not letter:
        raise HTTPException(status_code=404, detail="Letter not found")
    return letter


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
