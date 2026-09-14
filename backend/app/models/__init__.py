import enum
from datetime import date, datetime
from decimal import Decimal

from geoalchemy2 import Geography
from sqlalchemy import Boolean, Date, DateTime, Enum, ForeignKey, Integer, Numeric, String, Text, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.db import Base


class Role(str, enum.Enum):
    customer = "customer"
    worker = "worker"
    admin = "admin"


class BookingStatus(str, enum.Enum):
    requested = "requested"
    assigned = "assigned"
    accepted = "accepted"
    in_progress = "in_progress"
    completed = "completed"
    paid = "paid"
    rated = "rated"
    cancelled = "cancelled"


class Cooperative(Base):
    __tablename__ = "cooperatives"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(200))
    parent_id: Mapped[int | None] = mapped_column(ForeignKey("cooperatives.id"))
    area: Mapped[str | None] = mapped_column(String(100))
    lat: Mapped[float | None]
    lng: Mapped[float | None]
    children: Mapped[list["Cooperative"]] = relationship()


class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(primary_key=True)
    phone: Mapped[str] = mapped_column(String(15), unique=True)
    password_hash: Mapped[str] = mapped_column(String(200))
    role: Mapped[Role] = mapped_column(Enum(Role, native_enum=False, length=20))
    name: Mapped[str] = mapped_column(String(100))
    lang: Mapped[str] = mapped_column(String(5), default="en")


class Service(Base):
    __tablename__ = "services"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(100))
    category: Mapped[str] = mapped_column(String(100))
    base_price: Mapped[Decimal] = mapped_column(Numeric(10, 2))
    worker_share_pct: Mapped[int] = mapped_column(default=80)
    coop_share_pct: Mapped[int] = mapped_column(default=20)


class Skill(Base):
    __tablename__ = "skills"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(100))
    service_id: Mapped[int] = mapped_column(ForeignKey("services.id"))
    service: Mapped[Service] = relationship()


class WorkerSkill(Base):
    __tablename__ = "worker_skills"
    worker_id: Mapped[int] = mapped_column(ForeignKey("workers.id"), primary_key=True)
    skill_id: Mapped[int] = mapped_column(ForeignKey("skills.id"), primary_key=True)


class Worker(Base):
    __tablename__ = "workers"
    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), unique=True)
    coop_id: Mapped[int] = mapped_column(ForeignKey("cooperatives.id"))
    location = mapped_column(Geography("POINT", srid=4326), nullable=True)
    is_available: Mapped[bool] = mapped_column(default=True)
    experience_years: Mapped[int] = mapped_column(default=0)
    rating_avg: Mapped[float] = mapped_column(default=0.0)
    rating_count: Mapped[int] = mapped_column(default=0)
    jobs_this_week: Mapped[int] = mapped_column(default=0)
    has_insurance: Mapped[bool] = mapped_column(default=False)
    has_accident_cover: Mapped[bool] = mapped_column(default=False)
    is_coop_member: Mapped[bool] = mapped_column(default=True)
    user: Mapped[User] = relationship()
    coop: Mapped[Cooperative] = relationship()
    skills: Mapped[list[Skill]] = relationship(secondary="worker_skills")
    certifications: Mapped[list["WorkerCertification"]] = relationship(back_populates="worker")


class WorkerCertification(Base):
    __tablename__ = "worker_certifications"
    id: Mapped[int] = mapped_column(primary_key=True)
    worker_id: Mapped[int] = mapped_column(ForeignKey("workers.id"))
    name: Mapped[str] = mapped_column(String(200))
    file_path: Mapped[str | None] = mapped_column(String(500))
    verified_by: Mapped[int | None] = mapped_column(ForeignKey("users.id"))
    worker: Mapped[Worker] = relationship(back_populates="certifications")


class Customer(Base):
    __tablename__ = "customers"
    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), unique=True)
    default_location = mapped_column(Geography("POINT", srid=4326), nullable=True)
    user: Mapped[User] = relationship()


class Booking(Base):
    __tablename__ = "bookings"
    id: Mapped[int] = mapped_column(primary_key=True)
    customer_id: Mapped[int] = mapped_column(ForeignKey("customers.id"))
    worker_id: Mapped[int | None] = mapped_column(ForeignKey("workers.id"))
    service_id: Mapped[int] = mapped_column(ForeignKey("services.id"))
    location = mapped_column(Geography("POINT", srid=4326))
    lat: Mapped[float]
    lng: Mapped[float]
    address: Mapped[str] = mapped_column(String(300))
    scheduled_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    is_emergency: Mapped[bool] = mapped_column(default=False)
    status: Mapped[BookingStatus] = mapped_column(Enum(BookingStatus, native_enum=False, length=20), default=BookingStatus.requested)
    customer_price: Mapped[Decimal] = mapped_column(Numeric(10, 2))
    worker_wage: Mapped[Decimal] = mapped_column(Numeric(10, 2))
    coop_contribution: Mapped[Decimal] = mapped_column(Numeric(10, 2))
    razorpay_order_id: Mapped[str | None] = mapped_column(String(100))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    customer: Mapped[Customer] = relationship()
    worker: Mapped[Worker | None] = relationship()
    service: Mapped[Service] = relationship()
    rating: Mapped["Rating | None"] = relationship(back_populates="booking")


class Rating(Base):
    __tablename__ = "ratings"
    id: Mapped[int] = mapped_column(primary_key=True)
    booking_id: Mapped[int] = mapped_column(ForeignKey("bookings.id"), unique=True)
    stars: Mapped[int]
    comment: Mapped[str | None] = mapped_column(Text)
    booking: Mapped[Booking] = relationship(back_populates="rating")


class Invoice(Base):
    __tablename__ = "invoices"
    id: Mapped[int] = mapped_column(primary_key=True)
    booking_id: Mapped[int] = mapped_column(ForeignKey("bookings.id"), unique=True)
    number: Mapped[str] = mapped_column(String(30))
    html: Mapped[str] = mapped_column(Text)


class DemandHistory(Base):
    __tablename__ = "demand_history"
    __table_args__ = (UniqueConstraint("date", "service_id", "area"),)
    id: Mapped[int] = mapped_column(primary_key=True)
    date: Mapped[date] = mapped_column(Date)
    service_id: Mapped[int] = mapped_column(ForeignKey("services.id"))
    area: Mapped[str] = mapped_column(String(100))
    count: Mapped[int]


class Forecast(Base):
    __tablename__ = "forecasts"
    __table_args__ = (UniqueConstraint("date", "service_id", "area"),)
    id: Mapped[int] = mapped_column(primary_key=True)
    date: Mapped[date] = mapped_column(Date)
    service_id: Mapped[int] = mapped_column(ForeignKey("services.id"))
    area: Mapped[str] = mapped_column(String(100))
    predicted: Mapped[float]
    available_workers: Mapped[int]
    shortage: Mapped[int]
    generated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    service: Mapped[Service] = relationship()
