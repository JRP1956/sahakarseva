from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.core.security import (create_access_token, create_refresh_token, decode_token, get_current_user,
                               hash_password, verify_password)
from app.models import Customer, Role, User, Worker
from app.schemas.auth import LoginIn, RefreshIn, RegisterIn, TokenOut, UserOut

router = APIRouter(prefix="/auth", tags=["auth"])


def _issue(user: User) -> TokenOut:
    return TokenOut(access_token=create_access_token(user.id, user.role),
                    refresh_token=create_refresh_token(user.id), role=user.role)


@router.post("/register", response_model=TokenOut, status_code=201)
def register(body: RegisterIn, db: Session = Depends(get_db)):
    if body.role == Role.admin:
        raise HTTPException(400, "Admins are provisioned by the federation")
    if db.scalar(select(User).where(User.phone == body.phone)):
        raise HTTPException(409, "Phone already registered")
    if body.role == Role.worker and not body.coop_id:
        raise HTTPException(400, "coop_id required for workers")
    user = User(phone=body.phone, password_hash=hash_password(body.password), name=body.name, role=body.role, lang=body.lang)
    db.add(user)
    db.flush()
    if body.role == Role.worker:
        db.add(Worker(user_id=user.id, coop_id=body.coop_id))
    else:
        db.add(Customer(user_id=user.id))
    db.commit()
    return _issue(user)


def _login(db: Session, phone: str, password: str) -> TokenOut:
    user = db.scalar(select(User).where(User.phone == phone))
    if not user or not verify_password(password, user.password_hash):
        raise HTTPException(401, "Invalid credentials")
    return _issue(user)


@router.post("/login", response_model=TokenOut)
def login(body: LoginIn, db: Session = Depends(get_db)):
    return _login(db, body.phone, body.password)


@router.post("/token", response_model=TokenOut, include_in_schema=False)
def login_form(form: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    # lets the Swagger "Authorize" button work
    return _login(db, form.username, form.password)


@router.post("/refresh", response_model=TokenOut)
def refresh(body: RefreshIn, db: Session = Depends(get_db)):
    data = decode_token(body.refresh_token, "refresh")
    user = db.get(User, int(data["sub"]))
    if not user:
        raise HTTPException(401, "User not found")
    return TokenOut(access_token=create_access_token(user.id, user.role), role=user.role)


@router.get("/me", response_model=UserOut)
def me(user: User = Depends(get_current_user)):
    return user
