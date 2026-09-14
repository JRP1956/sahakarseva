from pydantic import BaseModel, Field

from app.models import Role


class RegisterIn(BaseModel):
    phone: str = Field(min_length=10, max_length=15)
    password: str = Field(min_length=6)
    name: str
    role: Role = Role.customer
    lang: str = "en"
    coop_id: int | None = None


class LoginIn(BaseModel):
    phone: str
    password: str


class TokenOut(BaseModel):
    access_token: str
    refresh_token: str | None = None
    role: Role
    token_type: str = "bearer"


class RefreshIn(BaseModel):
    refresh_token: str


class UserOut(BaseModel):
    id: int
    phone: str
    name: str
    role: Role
    lang: str
    model_config = {"from_attributes": True}
