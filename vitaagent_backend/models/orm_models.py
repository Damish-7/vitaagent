"""
models/orm_models.py
────────────────────
SQLAlchemy ORM models — mirror the schema.sql tables.
"""

from datetime import datetime, date
from sqlalchemy import (
    Column, Integer, String, Text, Date, DateTime,
    Enum, ForeignKey, DECIMAL, JSON, UniqueConstraint, SmallInteger
)
from sqlalchemy.orm import relationship
from database.connection import Base


class User(Base):
    __tablename__ = "users"

    id            = Column(Integer, primary_key=True, index=True)
    name          = Column(String(120), nullable=False)
    email         = Column(String(255), nullable=False, unique=True, index=True)
    password_hash = Column(String(255), nullable=False)
    plan          = Column(Enum("free", "premium", "enterprise"), default="free")
    avatar_url    = Column(String(500), nullable=True)
    created_at    = Column(DateTime, default=datetime.utcnow)
    updated_at    = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # relationships
    profile         = relationship("HealthProfile",  back_populates="user", uselist=False, cascade="all, delete")
    daily_metrics   = relationship("DailyMetric",    back_populates="user", cascade="all, delete")
    health_reports  = relationship("HealthReport",   back_populates="user", cascade="all, delete")
    clinical_history= relationship("ClinicalHistory",back_populates="user", cascade="all, delete")
    chat_history    = relationship("ChatHistory",    back_populates="user", cascade="all, delete")
    genetic_report  = relationship("GeneticReport",  back_populates="user", uselist=False, cascade="all, delete")
    diet_plans      = relationship("DietPlan",       back_populates="user", cascade="all, delete")
    exercise_plans  = relationship("ExercisePlan",   back_populates="user", cascade="all, delete")


class HealthProfile(Base):
    __tablename__ = "health_profiles"

    id           = Column(Integer, primary_key=True, index=True)
    user_id      = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    age          = Column(SmallInteger, nullable=True)
    blood_group  = Column(String(5),  nullable=True)
    height_cm    = Column(DECIMAL(5,2), nullable=True)
    weight_kg    = Column(DECIMAL(5,2), nullable=True)
    bmi          = Column(DECIMAL(5,2), nullable=True)
    step_goal    = Column(Integer, default=10000)
    calorie_goal = Column(Integer, default=2000)
    water_goal_l = Column(DECIMAL(4,2), default=2.5)
    updated_at   = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship("User", back_populates="profile")


class DailyMetric(Base):
    __tablename__ = "daily_metrics"
    __table_args__ = (UniqueConstraint("user_id", "metric_date"),)

    id                = Column(Integer, primary_key=True, index=True)
    user_id           = Column(Integer, ForeignKey("users.id"), nullable=False)
    metric_date       = Column(Date, nullable=False, index=True)
    steps             = Column(Integer, default=0)
    calories_burned   = Column(Integer, default=0)
    calories_consumed = Column(Integer, default=0)
    water_intake_l    = Column(DECIMAL(4,2), default=0.0)
    active_minutes    = Column(Integer, default=0)
    sleep_hours       = Column(DECIMAL(4,2), nullable=True)
    created_at        = Column(DateTime, default=datetime.utcnow)
    updated_at        = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship("User", back_populates="daily_metrics")


class HealthReport(Base):
    __tablename__ = "health_reports"

    id          = Column(Integer, primary_key=True, index=True)
    user_id     = Column(Integer, ForeignKey("users.id"), nullable=False)
    title       = Column(String(255), nullable=False)
    report_date = Column(Date, nullable=True)
    file_path   = Column(String(500), nullable=True)
    file_type   = Column(String(20), nullable=True)
    status      = Column(Enum("pending", "analyzed", "failed"), default="pending")
    ai_summary  = Column(Text, nullable=True)
    created_at  = Column(DateTime, default=datetime.utcnow)

    user    = relationship("User", back_populates="health_reports")
    metrics = relationship("ReportMetric", back_populates="report", cascade="all, delete")


class ReportMetric(Base):
    __tablename__ = "report_metrics"

    id          = Column(Integer, primary_key=True, index=True)
    report_id   = Column(Integer, ForeignKey("health_reports.id"), nullable=False)
    metric_name = Column(String(120), nullable=False)
    metric_val  = Column(String(120), nullable=False)

    report = relationship("HealthReport", back_populates="metrics")


class ClinicalHistory(Base):
    __tablename__ = "clinical_history"

    id         = Column(Integer, primary_key=True, index=True)
    user_id    = Column(Integer, ForeignKey("users.id"), nullable=False)
    event_date = Column(Date, nullable=False)
    title      = Column(String(255), nullable=False)
    summary    = Column(Text, nullable=False)
    source     = Column(Enum("manual", "report", "agent"), default="manual")
    report_id  = Column(Integer, ForeignKey("health_reports.id"), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="clinical_history")


class ChatHistory(Base):
    __tablename__ = "chat_history"

    id         = Column(Integer, primary_key=True, index=True)
    user_id    = Column(Integer, ForeignKey("users.id"), nullable=False)
    role       = Column(Enum("user", "assistant"), nullable=False)
    message    = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="chat_history")


class GeneticReport(Base):
    __tablename__ = "genetic_reports"

    id           = Column(Integer, primary_key=True, index=True)
    user_id      = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    report_ref   = Column(String(60), nullable=True)
    raw_json     = Column(JSON, nullable=True)
    processed_at = Column(DateTime, nullable=True)
    created_at   = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="genetic_report")


class DietPlan(Base):
    __tablename__ = "diet_plans"
    __table_args__ = (UniqueConstraint("user_id", "week_start"),)

    id         = Column(Integer, primary_key=True, index=True)
    user_id    = Column(Integer, ForeignKey("users.id"), nullable=False)
    week_start = Column(Date, nullable=False)
    plan_json  = Column(JSON, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="diet_plans")


class ExercisePlan(Base):
    __tablename__ = "exercise_plans"
    __table_args__ = (UniqueConstraint("user_id", "week_start"),)

    id         = Column(Integer, primary_key=True, index=True)
    user_id    = Column(Integer, ForeignKey("users.id"), nullable=False)
    week_start = Column(Date, nullable=False)
    plan_json  = Column(JSON, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="exercise_plans")