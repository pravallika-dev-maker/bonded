import logging
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.user import User
from ..models.relationship import Relationship
from ..core import security

logger = logging.getLogger("bonded.auth")
security_scheme = HTTPBearer()

async def get_current_user(db: Session = Depends(get_db), auth: HTTPAuthorizationCredentials = Depends(security_scheme)):
    token = auth.credentials
    logger.info(f"Raw token received by backend: '{token}'")
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, security.SECRET_KEY, algorithms=[security.ALGORITHM])
        phone_number: str = payload.get("sub")
        if phone_number is None:
            logger.error("JWT Error: 'sub' (phone_number) is None in the token payload.")
            raise credentials_exception
    except JWTError as e:
        logger.error(f"JWT Validation Error: {str(e)} - Token might be expired or signed with a different SECRET_KEY.")
        raise credentials_exception
        
    user = db.query(User).filter(User.phone_number == phone_number).first()
    if user is None:
        logger.error(f"Database Error: Token is valid, but user with phone_number '{phone_number}' does not exist in the database.")
        raise credentials_exception
    return user

def get_active_relationship(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if not current_user.partner_id:
        return None
        
    rel = db.query(Relationship).filter(
        ((Relationship.user1_id == current_user.id) & (Relationship.user2_id == current_user.partner_id)) |
        ((Relationship.user1_id == current_user.partner_id) & (Relationship.user2_id == current_user.id)),
        Relationship.status == "active"
    ).first()
    
    return rel
