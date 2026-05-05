"""
routes/health.py
────────────────
/api/metrics        — daily metrics CRUD
/api/reports        — health report upload + list
/api/history        — clinical history
/api/plans/diet     — diet plan CRUD
/api/plans/exercise — exercise plan CRUD
/api/dashboard      — combined dashboard data
"""

import os
import shutil
from datetime import date, timedelta
from pathlib import Path
from typing import List, Optional

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy.orm import Session

from database.connection import get_db
from models.orm_models import (
    User, HealthProfile, DailyMetric,
    HealthReport, ReportMetric,
    ClinicalHistory, DietPlan, ExercisePlan,
)
from models.schemas import (
    MetricUpsert, MetricResponse, WeeklyMetricsResponse,
    ProfileUpdate, ProfileResponse,
    ReportResponse,
    ClinicalEntryCreate, ClinicalEntryResponse,
    PlanUpsert, PlanResponse,
    DashboardResponse,
)
from services.auth_service import get_current_user

router = APIRouter(prefix="/api", tags=["health"])

UPLOAD_DIR = Path(os.getenv("UPLOAD_DIR", "uploads"))
UPLOAD_DIR.mkdir(exist_ok=True)


# ── Profile ────────────────────────────────────────────────────────────────

@router.get("/profile", response_model=ProfileResponse)
def get_profile(
    current_user: User    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    profile = db.query(HealthProfile).filter(
        HealthProfile.user_id == current_user.id
    ).first()
    if not profile:
        raise HTTPException(404, "Profile not found")
    return profile


@router.patch("/profile", response_model=ProfileResponse)
def update_profile(
    body:         ProfileUpdate,
    current_user: User    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    profile = db.query(HealthProfile).filter(
        HealthProfile.user_id == current_user.id
    ).first()
    if not profile:
        profile = HealthProfile(user_id=current_user.id)
        db.add(profile)

    for field, value in body.model_dump(exclude_none=True).items():
        setattr(profile, field, value)

    # auto-calculate BMI
    if profile.height_cm and profile.weight_kg:
        h = float(profile.height_cm) / 100
        profile.bmi = round(float(profile.weight_kg) / (h * h), 1)

    db.commit()
    db.refresh(profile)
    return profile


# ── Daily Metrics ──────────────────────────────────────────────────────────

@router.get("/metrics/today", response_model=MetricResponse)
def get_today_metrics(
    current_user: User    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    today  = date.today()
    metric = db.query(DailyMetric).filter(
        DailyMetric.user_id     == current_user.id,
        DailyMetric.metric_date == today,
    ).first()
    if not metric:
        # return zeros if no data yet
        metric = DailyMetric(
            user_id=current_user.id, metric_date=today,
            steps=0, calories_burned=0, calories_consumed=0,
            water_intake_l=0.0, active_minutes=0,
        )
    return metric


@router.get("/metrics/weekly", response_model=WeeklyMetricsResponse)
def get_weekly_metrics(
    current_user: User    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    today   = date.today()
    week_ago= today - timedelta(days=6)
    rows    = (
        db.query(DailyMetric)
        .filter(
            DailyMetric.user_id     == current_user.id,
            DailyMetric.metric_date >= week_ago,
        )
        .order_by(DailyMetric.metric_date)
        .all()
    )
    totals = {
        "steps":             sum(r.steps             for r in rows),
        "calories_burned":   sum(r.calories_burned   for r in rows),
        "calories_consumed": sum(r.calories_consumed for r in rows),
        "active_minutes":    sum(r.active_minutes    for r in rows),
    }
    return WeeklyMetricsResponse(days=rows, totals=totals)


@router.post("/metrics", response_model=MetricResponse)
def upsert_metrics(
    body:         MetricUpsert,
    current_user: User    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    target_date = body.metric_date or date.today()
    metric = db.query(DailyMetric).filter(
        DailyMetric.user_id     == current_user.id,
        DailyMetric.metric_date == target_date,
    ).first()

    if not metric:
        metric = DailyMetric(user_id=current_user.id, metric_date=target_date)
        db.add(metric)

    for field, value in body.model_dump(exclude_none=True, exclude={"metric_date"}).items():
        setattr(metric, field, value)

    db.commit()
    db.refresh(metric)
    return metric


# ── Health Reports ─────────────────────────────────────────────────────────

@router.get("/reports", response_model=List[ReportResponse])
def list_reports(
    current_user: User    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    return (
        db.query(HealthReport)
        .filter(HealthReport.user_id == current_user.id)
        .order_by(HealthReport.created_at.desc())
        .all()
    )


@router.post("/reports/upload", response_model=ReportResponse, status_code=201)
async def upload_report(
    file:         UploadFile = File(...),
    title:        str        = Form(...),
    report_date:  Optional[str] = Form(None),
    current_user: User       = Depends(get_current_user),
    db:           Session    = Depends(get_db),
):
    # validate file size
    max_bytes = int(os.getenv("MAX_FILE_SIZE_MB", "10")) * 1024 * 1024
    content   = await file.read()
    if len(content) > max_bytes:
        raise HTTPException(413, "File too large")

    # save file
    ext       = Path(file.filename).suffix.lower().lstrip(".")
    if ext not in ("pdf", "jpg", "jpeg", "png"):
        raise HTTPException(415, "Unsupported file type")

    user_dir  = UPLOAD_DIR / str(current_user.id)
    user_dir.mkdir(exist_ok=True)
    dest      = user_dir / file.filename
    dest.write_bytes(content)

    # create DB record
    parsed_date = date.fromisoformat(report_date) if report_date else None
    report = HealthReport(
        user_id=current_user.id,
        title=title,
        report_date=parsed_date,
        file_path=str(dest),
        file_type=ext,
        status="pending",
    )
    db.add(report)
    db.commit()
    db.refresh(report)

    # TODO: trigger async AI analysis task
    return report


# ── Clinical History ───────────────────────────────────────────────────────

@router.get("/history", response_model=List[ClinicalEntryResponse])
def get_history(
    current_user: User    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    return (
        db.query(ClinicalHistory)
        .filter(ClinicalHistory.user_id == current_user.id)
        .order_by(ClinicalHistory.event_date.desc())
        .all()
    )


@router.post("/history", response_model=ClinicalEntryResponse, status_code=201)
def add_history_entry(
    body:         ClinicalEntryCreate,
    current_user: User    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    entry = ClinicalHistory(user_id=current_user.id, **body.model_dump())
    db.add(entry)
    db.commit()
    db.refresh(entry)
    return entry


@router.delete("/history/{entry_id}", status_code=204)
def delete_history_entry(
    entry_id:     int,
    current_user: User    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    entry = db.query(ClinicalHistory).filter(
        ClinicalHistory.id      == entry_id,
        ClinicalHistory.user_id == current_user.id,
    ).first()
    if not entry:
        raise HTTPException(404, "Entry not found")
    db.delete(entry)
    db.commit()


# ── Plans ──────────────────────────────────────────────────────────────────

@router.get("/plans/diet", response_model=Optional[PlanResponse])
def get_diet_plan(
    current_user: User    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    return (
        db.query(DietPlan)
        .filter(DietPlan.user_id == current_user.id)
        .order_by(DietPlan.week_start.desc())
        .first()
    )


@router.post("/plans/diet", response_model=PlanResponse, status_code=201)
def upsert_diet_plan(
    body:         PlanUpsert,
    current_user: User    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    plan = db.query(DietPlan).filter(
        DietPlan.user_id    == current_user.id,
        DietPlan.week_start == body.week_start,
    ).first()
    if plan:
        plan.plan_json = body.plan_json
    else:
        plan = DietPlan(user_id=current_user.id, **body.model_dump())
        db.add(plan)
    db.commit()
    db.refresh(plan)
    return plan


@router.get("/plans/exercise", response_model=Optional[PlanResponse])
def get_exercise_plan(
    current_user: User    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    return (
        db.query(ExercisePlan)
        .filter(ExercisePlan.user_id == current_user.id)
        .order_by(ExercisePlan.week_start.desc())
        .first()
    )


@router.post("/plans/exercise", response_model=PlanResponse, status_code=201)
def upsert_exercise_plan(
    body:         PlanUpsert,
    current_user: User    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    plan = db.query(ExercisePlan).filter(
        ExercisePlan.user_id    == current_user.id,
        ExercisePlan.week_start == body.week_start,
    ).first()
    if plan:
        plan.plan_json = body.plan_json
    else:
        plan = ExercisePlan(user_id=current_user.id, **body.model_dump())
        db.add(plan)
    db.commit()
    db.refresh(plan)
    return plan


# ── Dashboard ──────────────────────────────────────────────────────────────

@router.get("/dashboard")
def get_dashboard(
    current_user: User    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    today    = date.today()
    week_ago = today - timedelta(days=6)

    today_metric = db.query(DailyMetric).filter(
        DailyMetric.user_id == current_user.id,
        DailyMetric.metric_date == today,
    ).first()

    weekly = (
        db.query(DailyMetric)
        .filter(
            DailyMetric.user_id     == current_user.id,
            DailyMetric.metric_date >= week_ago,
        )
        .order_by(DailyMetric.metric_date)
        .all()
    )

    profile = db.query(HealthProfile).filter(
        HealthProfile.user_id == current_user.id
    ).first()

    return {
        "user": {
            "id":   current_user.id,
            "name": current_user.name,
            "plan": current_user.plan,
        },
        "today_metrics": today_metric,
        "weekly_steps":  [r.steps for r in weekly],
        "profile": profile,
    }