# VitaAgent — AI Health Dashboard

A full-stack AI-powered personal health dashboard built with **Flutter** (frontend), **FastAPI + Python** (backend), and **MySQL via MAMP** (database), featuring a local **Qwen LLM** as the AI health assistant "Vijay".

---

## Table of Contents

- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Windows Setup Guide](#windows-setup-guide)
  - [Step 1 — Start MAMP & Create Database](#step-1--start-mamp--create-database)
  - [Step 2 — Configure Environment](#step-2--configure-environment)
  - [Step 3 — Python Virtual Environment](#step-3--python-virtual-environment)
  - [Step 4 — Run the Backend](#step-4--run-the-backend)
  - [Step 5 — Run the Flutter App](#step-5--run-the-flutter-app)
- [API Reference](#api-reference)
- [Database Schema](#database-schema)
- [Flutter App Pages](#flutter-app-pages)
- [AI / LLM Integration](#ai--llm-integration)
- [Environment Variables](#environment-variables)
- [Demo Credentials](#demo-credentials)
- [Troubleshooting](#troubleshooting)

---

## Project Overview

VitaAgent is a personal health management app powered by a local AI agent named **Vijay**. It lets users:

- Track daily steps, calories burned/consumed, and water intake
- Upload and analyze medical reports (PDF/images)
- View an AI-generated clinical history timeline
- Follow a personalized weekly diet and exercise plan
- Chat with Vijay (Qwen LLM) for real-time health advice
- View genetic report analysis (nutrigenomics)

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) — Windows / Android / iOS / Web |
| Backend | FastAPI (Python 3.10+) |
| Database | MySQL 8 via MAMP (phpMyAdmin) |
| ORM | SQLAlchemy 2.0 |
| Auth | JWT (python-jose) + bcrypt (passlib) |
| LLM | Qwen/Qwen2.5-0.5B-Instruct (HuggingFace Transformers) |
| LLM Fallback | Built-in rule-based keyword responses |
| Charts | fl_chart (Flutter) |
| HTTP | http package (Flutter), httpx (Python) |
| State | Provider (Flutter) |

---

## Project Structure

```
VitaAgent/
│
├── vitaagent_backend/               # Python FastAPI backend
│   ├── main.py                      # App entry point, lifespan, routers
│   ├── requirements.txt             # Python dependencies
│   ├── .env.example                 # Copy to .env and configure
│   │
│   ├── database/
│   │   ├── connection.py            # SQLAlchemy engine + get_db()
│   │   └── schema.sql               # Full MySQL schema + seed data
│   │
│   ├── models/
│   │   ├── orm_models.py            # SQLAlchemy ORM table definitions
│   │   └── schemas.py               # Pydantic request/response schemas
│   │
│   ├── routes/
│   │   ├── auth.py                  # /api/auth/* (register, login, me)
│   │   ├── chat.py                  # /api/chat/* (send, history, clear)
│   │   └── health.py                # /api/metrics, /api/reports, /api/history, /api/plans, /api/dashboard
│   │
│   └── services/
│       ├── auth_service.py          # JWT creation + bcrypt helpers
│       └── llm_service.py           # Qwen model loader + rule-based fallback
│
└── vitaagent_flutter/               # Flutter frontend app
    ├── pubspec.yaml                 # Flutter dependencies
    │
    └── lib/
        ├── main.dart                # App entry + MainShell navigation
        ├── theme/
        │   └── app_theme.dart       # Colors, typography, ThemeData
        ├── services/
        │   ├── api_service.dart     # All HTTP calls + JWT token storage
        │   └── chat_provider.dart   # ChangeNotifier for chat state
        ├── widgets/
        │   ├── shared_widgets.dart  # AppCard, ProgressBar, LevelBadge, etc.
        │   └── chat_widget.dart     # Floating chat FAB + slide-up panel
        └── screens/
            ├── dashboard_screen.dart       # Home: metrics, weekly chart, agent card
            ├── reports_screen.dart         # Report upload + list
            ├── genetic_report_screen.dart  # 8-tab genetic/nutrigenomics modal
            ├── charts_screen.dart          # Diet + exercise charts
            ├── diet_plan_screen.dart       # Weekly diet + exercise plan modal
            └── clinical_history_screen.dart # Patient profile + timeline
```

---

## Prerequisites

Install these before starting:

| Tool | Version | Download |
|------|---------|----------|
| MAMP for Windows | Latest | https://www.mamp.info/en/windows/ |
| Python | 3.10 or higher | https://www.python.org/downloads/ |
| Flutter SDK | 3.x | https://docs.flutter.dev/get-started/install/windows |
| Git | Any | https://git-scm.com |

Verify installations:
```cmd
python --version
flutter --version
```

---

## Windows Setup Guide

### Step 1 — Start MAMP & Create Database

**1a. Start MAMP**

1. Open MAMP application
2. Click **Start Servers** — wait for both Apache and MySQL lights to turn green
3. Confirm ports:
   - Apache → `8888`
   - MySQL → `8889`
4. Open phpMyAdmin at `http://localhost:8888/phpMyAdmin/`
5. Login: username `root`, password `root`

**1b. Create the database**

1. In phpMyAdmin left panel → click **New**
2. Database name: `vitaagent`
3. Collation: `utf8mb4_unicode_ci`
4. Click **Create**
5. Select the `vitaagent` database from the left panel
6. Click the **Import** tab at the top
7. Click **Choose File** → select `vitaagent_backend/database/schema.sql`
8. Click **Go**

You should see a success message. The schema creates 9 tables and seeds demo data automatically.

---

### Step 2 — Configure Environment

Navigate to the `vitaagent_backend/` folder. Copy the example file:

```cmd
cd C:\path\to\vitaagent_backend
copy .env.example .env
```

Open `.env` in any text editor (Notepad, VS Code, etc.) and confirm these values:

```ini
DB_HOST=127.0.0.1
DB_PORT=8889
DB_NAME=vitaagent
DB_USER=root
DB_PASSWORD=root

APP_HOST=0.0.0.0
APP_PORT=5000
DEBUG=true

LLM_MODEL=Qwen/Qwen2.5-0.5B-Instruct

SECRET_KEY=your-super-secret-key-change-this-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440

UPLOAD_DIR=uploads
MAX_FILE_SIZE_MB=10
```

Save the file.

---

### Step 3 — Python Virtual Environment

Open **Command Prompt** (not PowerShell) and run:

```cmd
cd C:\path\to\vitaagent_backend

:: Create the virtual environment
python -m venv venv

:: Activate it  (you must do this every time you open a new terminal)
venv\Scripts\activate

:: Your prompt will now show (venv) at the start

:: Install all dependencies
pip install -r requirements.txt
```

> **Note on LLM dependencies:** `torch` and `transformers` are approximately 2 GB. If your machine has limited RAM or a slow connection, you can remove those two lines from `requirements.txt` — the backend will automatically use the built-in rule-based fallback and still respond to all chat messages.

---

### Step 4 — Run the Backend

In the same terminal (with venv active):

```cmd
uvicorn main:app --host 0.0.0.0 --port 5000 --reload
```

Expected output:

```
══════════════════════════════════════════════════════════════
  VitaAgent Backend starting …
══════════════════════════════════════════════════════════════
[DB]  MySQL connection OK ✅
[DB]  Tables verified ✅
[LLM] Loading Qwen/Qwen2.5-0.5B-Instruct …   (or: Fallback mode)
══════════════════════════════════════════════════════════════
  API ready → http://localhost:5000
  Docs      → http://localhost:5000/docs
══════════════════════════════════════════════════════════════
```

Verify it works by opening `http://localhost:5000/health` in your browser. You should see:

```json
{
  "api": "ok",
  "database": "ok",
  "llm_loaded": true
}
```

The full interactive API docs (Swagger UI) are at `http://localhost:5000/docs`.

---

### Step 5 — Run the Flutter App

**5a. Fix the API base URL**

Open `vitaagent_flutter/lib/services/api_service.dart` and find this line near the top:

```dart
const String _baseUrl = 'http://localhost:5000';
```

Keep it as `localhost:5000` for Windows desktop or Chrome. For other targets:

| Target | Value |
|--------|-------|
| Windows desktop / Chrome | `http://localhost:5000` |
| Android emulator | `http://10.0.2.2:5000` |
| iOS simulator | `http://localhost:5000` |
| Real Android/iOS device | `http://192.168.x.x:5000` (your PC's local IP) |

**5b. Install Flutter dependencies and run**

Open a **new terminal** (separate from the backend terminal):

```cmd
cd C:\path\to\vitaagent_flutter

:: Install packages
flutter pub get

:: Run on Windows desktop
flutter run -d windows

:: Or run in Chrome
flutter run -d chrome

:: Or list available devices first
flutter devices
```

The app will build and launch. The first build may take 1–2 minutes.

---

## API Reference

All endpoints except `/api/auth/register` and `/api/auth/login` require an `Authorization: Bearer <token>` header.

### Authentication

| Method | Endpoint | Body | Description |
|--------|----------|------|-------------|
| POST | `/api/auth/register` | `{name, email, password}` | Create new user account |
| POST | `/api/auth/login` | `{email, password}` | Returns JWT access token |
| GET | `/api/auth/me` | — | Returns current user info |

### Dashboard

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/dashboard` | Combined today metrics + weekly steps + profile |

### Health Metrics

| Method | Endpoint | Body | Description |
|--------|----------|------|-------------|
| GET | `/api/metrics/today` | — | Today's step/calorie/water data |
| GET | `/api/metrics/weekly` | — | Last 7 days with totals |
| POST | `/api/metrics` | `{steps, calories_burned, ...}` | Upsert today's data |

### Health Profile

| Method | Endpoint | Body | Description |
|--------|----------|------|-------------|
| GET | `/api/profile` | — | User's health profile |
| PATCH | `/api/profile` | `{age, height_cm, weight_kg, ...}` | Update profile (auto-calculates BMI) |

### Reports

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/reports` | List all uploaded reports |
| POST | `/api/reports/upload` | Multipart upload (PDF/JPG/PNG, max 10 MB) |

### Clinical History

| Method | Endpoint | Body | Description |
|--------|----------|------|-------------|
| GET | `/api/history` | — | Full timeline descending |
| POST | `/api/history` | `{event_date, title, summary}` | Add manual entry |
| DELETE | `/api/history/{id}` | — | Delete an entry |

### Plans

| Method | Endpoint | Body | Description |
|--------|----------|------|-------------|
| GET | `/api/plans/diet` | — | Latest diet plan (JSON) |
| POST | `/api/plans/diet` | `{week_start, plan_json}` | Save diet plan |
| GET | `/api/plans/exercise` | — | Latest exercise plan (JSON) |
| POST | `/api/plans/exercise` | `{week_start, plan_json}` | Save exercise plan |

### Chat (Vijay AI)

| Method | Endpoint | Body | Description |
|--------|----------|------|-------------|
| POST | `/api/chat` | `{message}` | Send message, receive AI response (saved to DB) |
| GET | `/api/chat/history` | `?limit=50` | Retrieve conversation history |
| DELETE | `/api/chat/history` | — | Clear all chat history |

---

## Database Schema

The `schema.sql` file creates these 9 tables:

| Table | Purpose |
|-------|---------|
| `users` | Account credentials, plan type |
| `health_profiles` | Age, height, weight, BMI, daily goals |
| `daily_metrics` | Per-day steps, calories, water, sleep |
| `health_reports` | Uploaded report file metadata |
| `report_metrics` | Key-value pairs extracted from reports |
| `clinical_history` | Timeline entries (manual, report, agent) |
| `chat_history` | Full user↔Vijay conversation log |
| `genetic_reports` | Nutrigenomics data (JSON) |
| `diet_plans` | Weekly diet plan JSON per user |
| `exercise_plans` | Weekly exercise plan JSON per user |

---

## Flutter App Pages

| Screen | Route / Nav | Description |
|--------|-------------|-------------|
| Dashboard | Bottom nav 0 | Greeting, 4 metric cards, weekly bar chart, today's plan, agent card |
| Reports | Bottom nav 1 | Upload zone, genetic report CTA, analyzed reports list |
| Charts | Bottom nav 2 | Stacked diet bar chart, exercise line chart, macro breakdown |
| Clinical History | Bottom nav 3 | Patient profile card, vertical timeline |
| Genetic Report | Modal (from Reports) | 8-tab modal: Overview, Diet, Nutrition, Fitness, Sleep, Allergies, Disease Risk, Digestive |
| Diet & Exercise Plan | Modal (from Charts) | Tabbed plan view: meal selector with ingredients/steps + weekly exercise selector |
| Chat (Vijay) | FAB (all screens) | Slide-up chat panel, connects to `/api/chat` |

---

## AI / LLM Integration

**Primary:** Qwen/Qwen2.5-0.5B-Instruct loaded locally via HuggingFace Transformers.

The model is prompted to respond in structured JSON only:

```json
// For diet queries
{ "diet_plan": { "breakfast": [...], "lunch": [...], "dinner": [...] } }

// For exercise queries
{ "exercise_plan": { "morning": [...], "evening": [...], "tips": [...] } }

// For general health queries
{ "advice": "..." }
```

**Fallback:** If the model is not installed or fails to load, `llm_service.py` automatically falls back to a keyword-based rule system that still produces structured JSON responses for diet, exercise, and general advice queries. The Flutter app handles both response shapes identically.

---

## Environment Variables

Full reference for `.env`:

```ini
# MySQL connection (MAMP Windows defaults)
DB_HOST=127.0.0.1
DB_PORT=8889
DB_NAME=vitaagent
DB_USER=root
DB_PASSWORD=root

# FastAPI server
APP_HOST=0.0.0.0
APP_PORT=5000
DEBUG=true

# HuggingFace model ID (can be any Qwen Instruct model)
LLM_MODEL=Qwen/Qwen2.5-0.5B-Instruct

# JWT — change SECRET_KEY before deploying to production!
SECRET_KEY=your-super-secret-key-change-this-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440

# File uploads
UPLOAD_DIR=uploads
MAX_FILE_SIZE_MB=10
```

---

## Demo Credentials

The `schema.sql` seed inserts one ready-to-use account:

```
Email:    rahul@example.com
Password: password123
```

This account has a full health profile, 7 days of metrics, 4 clinical history entries, and a linked genetic report pre-loaded.

---

## Troubleshooting

**`(venv) not showing` / `uvicorn not found`**
The virtual environment is not activated. Run `venv\Scripts\activate` from the `vitaagent_backend/` directory before any Python command.

**`Can't connect to MySQL server (2003)`**
MAMP is not running, or `DB_PORT` in `.env` is wrong. Confirm MAMP shows green MySQL light and `DB_PORT=8889`.

**`Table 'vitaagent.users' doesn't exist`**
The schema was not imported. Open phpMyAdmin → select `vitaagent` DB → Import tab → choose `schema.sql` → click Go.

**`Port 5000 already in use`**
Change to a free port: `uvicorn main:app --port 8000 --reload`, then update `_baseUrl` in `api_service.dart` to `http://localhost:8000`.

**Flutter `SocketException: Connection refused` on Android device**
Use your PC's local IP address instead of `localhost`. Find it by running `ipconfig` in cmd and looking for the IPv4 address (usually `192.168.x.x`). Update `_baseUrl = 'http://192.168.x.x:5000'`.

**`torch` / `transformers` install fails or is very slow**
Remove `torch` and `transformers` lines from `requirements.txt`, then reinstall. The LLM fallback in `llm_service.py` activates automatically and still answers all chat messages.

**Flutter build error after `flutter pub get`**
Run `flutter clean` followed by `flutter pub get`, then try again.

**`401 Unauthorized` on all API calls in Flutter**
The JWT token has expired (default 24 hours) or was never saved. The app currently uses static demo data — wire up `AuthService.login()` to the login screen to get a fresh token stored in `SharedPreferences`.