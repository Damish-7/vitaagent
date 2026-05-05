"""
models/schemas.py
─────────────────
Pydantic v2 schemas for request bodies and API responses.
"""

from __future__ import annotations
from datetime import date, datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, EmailStr, field_validator


# ── Auth ───────────────────────────────────────────────────────────────────

class UserRegister(BaseModel):
    name:     str
    email:    EmailStr
    password: str
    plan:     str = "free"

class UserLogin(BaseModel):
    email:    EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type:   str = "bearer"
    user_id:      int
    name:         str
    plan:         str


# ── Health Profile ─────────────────────────────────────────────────────────

class ProfileUpdate(BaseModel):
    age:          Optional[int]   = None
    blood_group:  Optional[str]   = None
    height_cm:    Optional[float] = None
    weight_kg:    Optional[float] = None
    step_goal:    Optional[int]   = None
    calorie_goal: Optional[int]   = None
    water_goal_l: Optional[float] = None

class ProfileResponse(BaseModel):
    user_id:      int
    age:          Optional[int]
    blood_group:  Optional[str]
    height_cm:    Optional[float]
    weight_kg:    Optional[float]
    bmi:          Optional[float]
    step_goal:    int
    calorie_goal: int
    water_goal_l: float

    model_config = {"from_attributes": True}


# ── Daily Metrics ──────────────────────────────────────────────────────────

class MetricUpsert(BaseModel):
    metric_date:       Optional[date]  = None   # defaults to today
    steps:             Optional[int]   = None
    calories_burned:   Optional[int]   = None
    calories_consumed: Optional[int]   = None
    water_intake_l:    Optional[float] = None
    active_minutes:    Optional[int]   = None
    sleep_hours:       Optional[float] = None

class MetricResponse(BaseModel):
    id:                int
    user_id:           int
    metric_date:       date
    steps:             int
    calories_burned:   int
    calories_consumed: int
    water_intake_l:    float
    active_minutes:    int
    sleep_hours:       Optional[float]

    model_config = {"from_attributes": True}

class WeeklyMetricsResponse(BaseModel):
    days:   List[MetricResponse]
    totals: Dict[str, Any]


# ── Health Reports ─────────────────────────────────────────────────────────

class ReportMetricSchema(BaseModel):
    metric_name: str
    metric_val:  str

    model_config = {"from_attributes": True}

class ReportResponse(BaseModel):
    id:          int
    title:       str
    report_date: Optional[date]
    file_type:   Optional[str]
    status:      str
    ai_summary:  Optional[str]
    metrics:     List[ReportMetricSchema] = []
    created_at:  datetime

    model_config = {"from_attributes": True}


# ── Clinical History ───────────────────────────────────────────────────────

class ClinicalEntryCreate(BaseModel):
    event_date: date
    title:      str
    summary:    str
    source:     str = "manual"
    report_id:  Optional[int] = None

class ClinicalEntryResponse(BaseModel):
    id:         int
    event_date: date
    title:      str
    summary:    str
    source:     str
    created_at: datetime

    model_config = {"from_attributes": True}


# ── Chat ───────────────────────────────────────────────────────────────────

class ChatRequest(BaseModel):
    message: str

class ChatMessageResponse(BaseModel):
    id:         int
    role:       str
    message:    str
    created_at: datetime

    model_config = {"from_attributes": True}

class ChatResponse(BaseModel):
    response: Any
    history:  Optional[List[ChatMessageResponse]] = None


# ── Plans ──────────────────────────────────────────────────────────────────

class PlanUpsert(BaseModel):
    week_start: date
    plan_json:  Dict[str, Any]

class PlanResponse(BaseModel):
    id:         int
    week_start: date
    plan_json:  Dict[str, Any]
    created_at: datetime

    model_config = {"from_attributes": True}


# ── Genetic Report ─────────────────────────────────────────────────────────

class GeneticReportResponse(BaseModel):
    id:           int
    report_ref:   Optional[str]
    raw_json:     Optional[Dict[str, Any]]
    processed_at: Optional[datetime]

    model_config = {"from_attributes": True}


# ── Dashboard summary ──────────────────────────────────────────────────────

class DashboardResponse(BaseModel):
    user:           Dict[str, Any]
    today_metrics:  Optional[MetricResponse]
    weekly_steps:   List[int]
    profile:        Optional[ProfileResponse]