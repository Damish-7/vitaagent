"""
main.py
───────
VitaAgent FastAPI backend
  • MySQL via SQLAlchemy + PyMySQL (MAMP)
  • Qwen LLM (with rule-based fallback)
  • JWT authentication
  • Full REST API for the Flutter frontend

Start with:
    uvicorn main:app --host 0.0.0.0 --port 5000 --reload
"""

import os
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv

load_dotenv()

from database.connection import engine, test_connection
from models.orm_models import Base  # noqa: F401 — registers all models
from routes import auth, chat, health
from services import llm_service


# ── Lifespan (startup / shutdown) ─────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI):
    # ── Startup ──
    print("═" * 60)
    print("  VitaAgent Backend starting …")
    print("═" * 60)

    # 1. DB connectivity check
    if test_connection():
        print("[DB]  MySQL connection OK ✅")
        # Create any missing tables (safe on existing DBs)
        Base.metadata.create_all(bind=engine)
        print("[DB]  Tables verified ✅")
    else:
        print("[DB]  ⚠️  Could not connect to MySQL.")
        print("      Make sure MAMP is running and .env is correct.")

    # 2. Load LLM (non-blocking — falls back gracefully)
    llm_service.load_model()

    print("═" * 60)
    print(f"  API ready → http://localhost:{os.getenv('APP_PORT', 5000)}")
    print(f"  Docs      → http://localhost:{os.getenv('APP_PORT', 5000)}/docs")
    print("═" * 60)

    yield

    # ── Shutdown ──
    print("[Server] Shutting down …")


# ── App ────────────────────────────────────────────────────────────────────

app = FastAPI(
    title       = "VitaAgent API",
    description = "AI-powered health dashboard backend — Flutter + MySQL",
    version     = "1.0.0",
    lifespan    = lifespan,
)

# CORS — allow the Flutter debug runner and any local dev origin
app.add_middleware(
    CORSMiddleware,
    allow_origins     = ["*"],   # tighten this in production
    allow_credentials = True,
    allow_methods     = ["*"],
    allow_headers     = ["*"],
)

# Serve uploaded files
UPLOAD_DIR = os.getenv("UPLOAD_DIR", "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

# ── Routers ────────────────────────────────────────────────────────────────
app.include_router(auth.router)
app.include_router(chat.router)
app.include_router(health.router)


# ── Health-check ───────────────────────────────────────────────────────────
@app.get("/", tags=["root"])
def root():
    return {"status": "ok", "message": "VitaAgent API is running 🚀"}


@app.get("/health", tags=["root"])
def health_check():
    db_ok = test_connection()
    return {
        "api": "ok",
        "database": "ok" if db_ok else "unreachable",
        "llm_loaded": llm_service._loaded,
    }


# ── Dev runner ─────────────────────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host   = os.getenv("APP_HOST", "0.0.0.0"),
        port   = int(os.getenv("APP_PORT", 5000)),
        reload = os.getenv("DEBUG", "true").lower() == "true",
    )