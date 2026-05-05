# VitaAgent Backend — Python + MySQL (MAMP)

A FastAPI backend with MySQL database via phpMyAdmin/MAMP, replacing the
original Node.js + Express proxy.

---

## Architecture

```
Flutter App  ──►  FastAPI (port 5000)  ──►  MySQL (MAMP, port 8889)
                        │
                        └──►  Qwen LLM (local, with rule-based fallback)
```

---

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Python | 3.10+ | `python --version` |
| MAMP | latest | Download from mamp.info |
| pip | latest | comes with Python |

---

## 1 — Start MAMP

1. Open **MAMP** → click **Start Servers**
2. Default ports: Apache 8888, MySQL **8889** (Mac) / **3306** (Windows)
3. Open **phpMyAdmin** → `http://localhost:8888/phpMyAdmin/`

---

## 2 — Create the Database

### Option A — phpMyAdmin Import (recommended)

1. In phpMyAdmin, click **New** in the left sidebar
2. Name it `vitaagent`, charset `utf8mb4_unicode_ci`, click **Create**
3. Select the `vitaagent` database → click **Import** tab
4. Choose `database/schema.sql` → click **Go**

### Option B — Command line

```bash
# Mac MAMP
/Applications/MAMP/Library/bin/mysql -u root -proot -P 8889 < database/schema.sql

# Windows MAMP
"C:\MAMP\bin\mysql\bin\mysql.exe" -u root -proot -P 3306 < database/schema.sql
```

---

## 3 — Configure Environment

```bash
cp .env.example .env
```

Edit `.env` — key settings:

```ini
# Mac MAMP uses port 8889 by default
DB_PORT=8889

# Windows MAMP uses 3306
# DB_PORT=3306

DB_PASSWORD=root   # MAMP default
DB_NAME=vitaagent
```

---

## 4 — Install Python Dependencies

```bash
# Create a virtual environment (recommended)
python -m venv venv
source venv/bin/activate        # Mac/Linux
# venv\Scripts\activate.bat     # Windows

pip install -r requirements.txt
```

> **Note:** `torch` and `transformers` are large (~2 GB).
> If you don't need the LLM locally, remove them from `requirements.txt`
> — the backend will use the built-in rule-based fallback automatically.

---

## 5 — Run the Backend

```bash
uvicorn main:app --host 0.0.0.0 --port 5000 --reload
```

You should see:

```
══════════════════════════════════════════════════════════
  VitaAgent Backend starting …
══════════════════════════════════════════════════════════
[DB]  MySQL connection OK ✅
[DB]  Tables verified ✅
[LLM] Loading Qwen/Qwen2.5-0.5B-Instruct …
══════════════════════════════════════════════════════════
  API ready → http://localhost:5000
  Docs      → http://localhost:5000/docs
══════════════════════════════════════════════════════════
```

---

## 6 — Interactive API Docs

Open `http://localhost:5000/docs` for the full Swagger UI.

---

## API Reference

### Auth

| Method | Path | Body | Description |
|--------|------|------|-------------|
| POST | `/api/auth/register` | `{name, email, password}` | Create account |
| POST | `/api/auth/login` | `{email, password}` | Get JWT token |
| GET | `/api/auth/me` | — | Current user info |

### Health Data

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/dashboard` | Combined dashboard data |
| GET | `/api/metrics/today` | Today's metrics |
| GET | `/api/metrics/weekly` | Last 7 days |
| POST | `/api/metrics` | Upsert today's metrics |
| GET | `/api/profile` | Health profile |
| PATCH | `/api/profile` | Update profile |

### Reports

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/reports` | List all reports |
| POST | `/api/reports/upload` | Upload PDF/image (multipart) |

### History & Plans

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/history` | Clinical timeline |
| POST | `/api/history` | Add manual entry |
| GET | `/api/plans/diet` | Current diet plan |
| POST | `/api/plans/diet` | Save diet plan |
| GET | `/api/plans/exercise` | Current exercise plan |
| POST | `/api/plans/exercise` | Save exercise plan |

### Chat (Vijay AI)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/chat` | Send message, get AI response |
| GET | `/api/chat/history` | Fetch saved conversation |
| DELETE | `/api/chat/history` | Clear conversation |

---

## Demo Login

The schema seeds a demo user:

```
Email:    rahul@example.com
Password: password123
```

---

## Flutter — Connecting the App

In `lib/services/api_service.dart`, change the base URL constant:

```dart
// For Android emulator → use 10.0.2.2 instead of localhost
const String _baseUrl = 'http://10.0.2.2:5000';

// For iOS simulator or desktop → localhost works fine
const String _baseUrl = 'http://localhost:5000';

// For a real device on the same Wi-Fi
const String _baseUrl = 'http://192.168.x.x:5000';
```

The Flutter app stores the JWT in `SharedPreferences` and sends it
as `Authorization: Bearer <token>` on every request.

---

## Project Structure

```
vitaagent_backend/
├── main.py                  # FastAPI app entry point
├── requirements.txt
├── .env.example             # copy to .env and configure
├── database/
│   ├── connection.py        # SQLAlchemy engine + get_db()
│   └── schema.sql           # Import into phpMyAdmin
├── models/
│   ├── orm_models.py        # SQLAlchemy ORM models
│   └── schemas.py           # Pydantic request/response schemas
├── routes/
│   ├── auth.py              # /api/auth/*
│   ├── chat.py              # /api/chat/*
│   └── health.py            # /api/metrics, /api/reports, etc.
└── services/
    ├── auth_service.py      # JWT + bcrypt helpers
    └── llm_service.py       # Qwen model wrapper + fallback
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `Can't connect to MySQL` | Make sure MAMP is running; check DB_PORT in .env |
| `Module not found` | Activate venv: `source venv/bin/activate` |
| `LLM not loading` | GPU/RAM issue — fallback is automatic, no action needed |
| Flutter `SocketException` | Use `10.0.2.2` for Android emulator, not `localhost` |
| `401 Unauthorized` in Flutter | Token expired — log in again |
