"""
database/connection.py
──────────────────────
SQLAlchemy engine + session factory wired to MAMP MySQL.
"""

import os
from sqlalchemy import create_engine, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

load_dotenv()

# ── Build the MySQL URL ────────────────────────────────────────────────────
DB_HOST     = os.getenv("DB_HOST",     "127.0.0.1")
DB_PORT     = os.getenv("DB_PORT",     "8889")        # MAMP default on Mac
DB_NAME     = os.getenv("DB_NAME",     "vitaagent")
DB_USER     = os.getenv("DB_USER",     "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "root")

DATABASE_URL = (
    f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}"
    f"@{DB_HOST}:{DB_PORT}/{DB_NAME}?charset=utf8mb4"
)

# ── Engine ─────────────────────────────────────────────────────────────────
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,       # detect stale connections
    pool_recycle=3600,        # recycle every hour
    echo=os.getenv("DEBUG", "false").lower() == "true",
)

# ── Session factory ────────────────────────────────────────────────────────
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# ── Base class for ORM models ──────────────────────────────────────────────
Base = declarative_base()


def get_db():
    """FastAPI dependency — yields a DB session, always closes it."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def test_connection() -> bool:
    """Return True if the DB is reachable."""
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return True
    except Exception as exc:
        print(f"[DB] Connection failed: {exc}")
        return False