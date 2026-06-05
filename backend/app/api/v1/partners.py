from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ...database import get_db
from ..deps import get_current_user
from ...models.user import User
from ...models.invite_code import InviteCode
from ...schemas.partner import InviteCodeResponse, JoinRequest, JoinResponse, PartnerMeResponse
from ...services.notification_service import create_notification, create_notification_and_push
from datetime import datetime, timedelta, timezone
import random

router = APIRouter(prefix="/partners", tags=["Partners"])

WORD_LIST = ['ROSE', 'LUNA', 'NOVA', 'EDEN', 'SAGE', 'IRIS', 'DAWN', 'STAR', 'VEIL', 'MIST']

@router.get("/invite-code", response_model=InviteCodeResponse)
def get_invite_code(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    # 1. Delete any old unused codes for this user
    db.query(InviteCode).filter(InviteCode.creator_id == current_user.id, InviteCode.is_used == False).delete()
    
    # 2. Pick a random word from list + random digit
    code_str = f"{random.choice(WORD_LIST)}-{random.randint(1, 9)}"
    
    # Check uniqueness (extremely rare collision but good practice)
    while db.query(InviteCode).filter(InviteCode.code == code_str).first() is not None:
        code_str = f"{random.choice(WORD_LIST)}-{random.randint(1, 9)}"
        
    # 3. Save to invite_codes table
    expires_at = datetime.now(timezone.utc) + timedelta(hours=24)
    new_code = InviteCode(code=code_str, creator_id=current_user.id, expires_at=expires_at)
    db.add(new_code)
    db.commit()
    db.refresh(new_code)
    
    # 4. Return the code + expires_at
    return InviteCodeResponse(code=new_code.code, expires_at=new_code.expires_at, success=True)

@router.post("/join", response_model=JoinResponse)
def join_partner(request: JoinRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    code_str = request.code.upper().strip()
    
    # 1. Find code in invite_codes where is_used=False and expires_at > now
    invite = db.query(InviteCode).filter(
        InviteCode.code == code_str, 
        InviteCode.is_used == False,
        InviteCode.expires_at > datetime.now(timezone.utc)
    ).first()
    
    # 2. If not found -> return 404 "Invalid or expired code"
    if not invite:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Invalid or expired code")
        
    # 3. If creator_id == current_user.id -> return 400 "Cannot join your own code"
    if invite.creator_id == current_user.id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot join your own code")
        
    # Get the creator
    creator = db.query(User).filter(User.id == invite.creator_id).first()
    if not creator:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Creator not found")
        
    # 4. Set current_user.partner_id = code.creator_id
    current_user.partner_id = creator.id
    
    # 5. Set creator.partner_id = current_user.id
    creator.partner_id = current_user.id
    
    # 6. Set both users is_partnered = True
    current_user.is_partnered = True
    creator.is_partnered = True
    
    # 7. Mark code is_used = True
    invite.is_used = True
    
    # 8. Commit DB
    db.commit()
    
    # Notify creator
    create_notification_and_push(
        db,
        recipient_id=creator.id,
        notification_type="partner_joined",
        title=f"{current_user.user_name or 'Your partner'} joined your bond! 💕",
        body="You are now connected.",
        fcm_token=creator.fcm_token
    )

    # 9. Return { success: true, partner_name: creator.user_name }
    return JoinResponse(
        success=True, 
        partner_name=creator.user_name or "Your Partner", 
        message="Successfully connected!"
    )

@router.get("/me", response_model=PartnerMeResponse)
def get_partner_me(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if not current_user.is_partnered or not current_user.partner_id:
        return PartnerMeResponse(partner_name=None, is_connected=False)
        
    partner = db.query(User).filter(User.id == current_user.partner_id).first()
    if not partner:
        return PartnerMeResponse(partner_name=None, is_connected=False)
        
    return PartnerMeResponse(partner_name=partner.user_name, is_connected=True)

@router.delete("/disconnect")
def disconnect_partner(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if not current_user.partner_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="You do not have a partner connected")
        
    partner = db.query(User).filter(User.id == current_user.partner_id).first()
    
    # Set both users partner_id = None, is_partnered = False
    current_user.partner_id = None
    current_user.is_partnered = False
    
    if partner:
        partner.partner_id = None
        partner.is_partnered = False
        
        create_notification_and_push(
            db,
            recipient_id=partner.id,
            notification_type="partner_disconnected",
            title="Your bond has been disconnected",
            body=f"{current_user.user_name or 'Your partner'} has disconnected.",
            fcm_token=partner.fcm_token
        )
        
    db.commit()
    return {"success": True, "message": "Successfully disconnected"}
