"""
routes/auth.py
──────────────
POST /api/auth/register
POST /api/auth/login
GET  /api/auth/me
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from database.connection import get_db
from models.orm_models import User, HealthProfile
from models.schemas import UserRegister, UserLogin, TokenResponse
from services.auth_service import (
    hash_password, verify_password,
    create_access_token, get_current_user,
)

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.post("/register", response_model=TokenResponse, status_code=201)
def register(body: UserRegister, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == body.email).first():
        raise HTTPException(status_code=409, detail="Email already registered")

    user = User(
        name=body.name,
        email=body.email,
        password_hash=hash_password(body.password),
        plan=body.plan,
    )
    db.add(user)
    db.flush()   # get user.id before commit

    # create empty health profile
    db.add(HealthProfile(user_id=user.id))
    db.commit()
    db.refresh(user)

    token = create_access_token({"sub": user.id})
    return TokenResponse(
        access_token=token,
        user_id=user.id,
        name=user.name,
        plan=user.plan,
    )


@router.post("/login", response_model=TokenResponse)
def login(body: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == body.email).first()
    if not user or not verify_password(body.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
        )
    token = create_access_token({"sub": user.id})
    return TokenResponse(
        access_token=token,
        user_id=user.id,
        name=user.name,
        plan=user.plan,
    )


@router.get("/me")
def me(current_user: User = Depends(get_current_user)):
    return {
        "id":    current_user.id,
        "name":  current_user.name,
        "email": current_user.email,
        "plan":  current_user.plan,
    }