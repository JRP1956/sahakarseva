from datetime import datetime, timedelta, timezone

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from passlib.context import CryptContext
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.db import get_db
from app.models import Role, User

pwd = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2 = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/token")
ALG = "HS256"


def hash_password(p: str) -> str:
    return pwd.hash(p)


def verify_password(p: str, h: str) -> bool:
    return pwd.verify(p, h)


def _token(payload: dict, ttl: timedelta) -> str:
    payload = {**payload, "exp": datetime.now(timezone.utc) + ttl}
    return jwt.encode(payload, settings.jwt_secret, algorithm=ALG)


def create_access_token(user_id: int, role: Role) -> str:
    return _token({"sub": str(user_id), "role": role.value, "typ": "access"}, timedelta(minutes=15))


def create_refresh_token(user_id: int) -> str:
    return _token({"sub": str(user_id), "typ": "refresh"}, timedelta(days=30))


def decode_token(token: str, typ: str) -> dict:
    try:
        data = jwt.decode(token, settings.jwt_secret, algorithms=[ALG])
    except JWTError:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid token")
    if data.get("typ") != typ:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Wrong token type")
    return data


def get_current_user(token: str = Depends(oauth2), db: Session = Depends(get_db)) -> User:
    data = decode_token(token, "access")
    user = db.get(User, int(data["sub"]))
    if not user:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "User not found")
    return user


def require_role(*roles: Role):
    def dep(user: User = Depends(get_current_user)) -> User:
        if user.role not in roles:
            raise HTTPException(status.HTTP_403_FORBIDDEN, "Insufficient role")
        return user
    return dep
