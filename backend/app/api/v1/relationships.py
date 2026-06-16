from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import date
from ...database import get_db
from ..deps import get_current_user
from ...models.user import User
from ...models.relationship import Relationship
from ...models.letter import Letter
from ...models.separation import Separation
from ...schemas.relationship import RelationshipHistoryItem, RelationshipSummaryResponse
from ...schemas.letter import LetterResponse
from ...schemas.separation import SeparationResponse
from typing import List

router = APIRouter(prefix="/relationships", tags=["Relationships"])

def verify_relationship_access(rel_id: int, user_id: int, db: Session) -> Relationship:
    rel = db.query(Relationship).filter(Relationship.id == rel_id).first()
    if not rel:
        raise HTTPException(status_code=404, detail="Relationship not found")
    if rel.user1_id != user_id and rel.user2_id != user_id:
        raise HTTPException(status_code=403, detail="You do not have access to this relationship data")
    return rel

@router.get("/history", response_model=List[RelationshipHistoryItem])
def get_relationship_history(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rels = db.query(Relationship).filter(
        (Relationship.user1_id == current_user.id) | (Relationship.user2_id == current_user.id)
    ).order_by(Relationship.created_at.desc()).all()
    
    result = []
    for r in rels:
        partner_id = r.user2_id if r.user1_id == current_user.id else r.user1_id
        partner = db.query(User).filter(User.id == partner_id).first()
        
        # Determine partner name (use persisted name if archived, live database name otherwise)
        if r.status == "archived":
            partner_name = r.user2_name if r.user1_id == current_user.id else r.user1_name
        else:
            partner_name = partner.user_name if (partner and partner.user_name) else current_user.partner_name
        
        sep_count = db.query(Separation).filter(Separation.relationship_id == r.id).count()
        
        # Use persisted type if archived, or current_user's relation_type if active
        if r.status == "archived":
            rel_type = r.relationship_type
        else:
            rel_type = current_user.relation_type or (partner.relation_type if partner else None)
        
        result.append(RelationshipHistoryItem(
            relationship_id=r.id,
            partner_name=partner_name,
            partner_gender=partner.gender if partner else None,
            status=r.status,
            journey_score=r.journey_score,
            separation_count=sep_count,
            started_at=r.created_at,
            ended_at=r.ended_at,
            relationship_type=rel_type
        ))
        
    return result

@router.get("/{relationship_id}/letters", response_model=List[LetterResponse])
def get_relationship_letters(relationship_id: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    verify_relationship_access(relationship_id, current_user.id, db)
    # We only show letters written by the current user, or revealed letters from the partner.
    # To keep history simple, let's just return all letters belonging to the current user in that relationship.
    # The spec says "Return all letters associated with that relationship."
    letters = db.query(Letter).filter(
        Letter.relationship_id == relationship_id,
        Letter.author_id == current_user.id
    ).order_by(Letter.created_at.desc()).all()
    
    return letters

@router.get("/{relationship_id}/separations", response_model=List[SeparationResponse])
def get_relationship_separations(relationship_id: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    verify_relationship_access(relationship_id, current_user.id, db)
    
    seps = db.query(Separation).filter(
        Separation.relationship_id == relationship_id
    ).order_by(Separation.created_at.desc()).all()
    
    rel = db.query(Relationship).filter(Relationship.id == relationship_id).first()

    # Resolve partner_name once for all separations in this relationship:
    # For archived relationships, use the historically stored names on the relationship record.
    # For active relationships, do a live lookup then fall back to onboarding partner_name.
    if rel.status == "archived":
        partner_name = rel.user2_name if rel.user1_id == current_user.id else rel.user1_name
    else:
        partner_id = rel.user2_id if rel.user1_id == current_user.id else rel.user1_id
        partner = db.query(User).filter(User.id == partner_id).first()
        partner_name = (partner.user_name if (partner and partner.user_name) else None) or current_user.partner_name
    
    for s in seps:
        s.days_elapsed = (s.ended_at.date() - s.start_date).days if s.ended_at else (date.today() - s.start_date).days
        s.partner_name = partner_name
        
    return seps

@router.get("/{relationship_id}/summary", response_model=RelationshipSummaryResponse)
def get_relationship_summary(relationship_id: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rel = verify_relationship_access(relationship_id, current_user.id, db)
    
    partner_id = rel.user2_id if rel.user1_id == current_user.id else rel.user1_id
    partner = db.query(User).filter(User.id == partner_id).first()
    
    sep_count = db.query(Separation).filter(Separation.relationship_id == relationship_id).count()
    
    end_date = rel.ended_at.date() if rel.ended_at else date.today()
    duration_days = (end_date - rel.created_at.date()).days
    
    # Use persisted type if archived, or current_user's relation_type if active
    if rel.status == "archived":
        rel_type = rel.relationship_type
    else:
        rel_type = current_user.relation_type or (partner.relation_type if partner else None)
    
    # Determine partner name (use persisted name if archived, live database name otherwise)
    if rel.status == "archived":
        partner_name = rel.user2_name if rel.user1_id == current_user.id else rel.user1_name
    else:
        partner_name = partner.user_name if (partner and partner.user_name) else current_user.partner_name
        
    return RelationshipSummaryResponse(
        relationship_id=rel.id,
        partner_name=partner_name,
        partner_gender=partner.gender if partner else None,
        journey_score=rel.journey_score,
        separation_count=sep_count,
        relationship_duration_days=max(0, duration_days),
        status=rel.status,
        relationship_type=rel_type,
        relationship_summary=rel.summary_insight
    )


