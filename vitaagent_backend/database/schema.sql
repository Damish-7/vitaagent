-- ══════════════════════════════════════════════════════════════════════════
--  VitaAgent — MySQL Schema
--  Import this file via phpMyAdmin → Import tab, or run:
--      mysql -u root -p vitaagent < schema.sql
--
--  MAMP users: the socket / port may differ. Use phpMyAdmin to create the
--  database first, then import this script into it.
-- ══════════════════════════════════════════════════════════════════════════

CREATE DATABASE IF NOT EXISTS vitaagent
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE vitaagent;

-- ── Users ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id            INT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(120) NOT NULL,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    plan          ENUM('free','premium','enterprise') NOT NULL DEFAULT 'free',
    avatar_url    VARCHAR(500) NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                              ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Health Profiles ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS health_profiles (
    id              INT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id         INT          NOT NULL UNIQUE,
    age             TINYINT UNSIGNED NULL,
    blood_group     VARCHAR(5)   NULL,
    height_cm       DECIMAL(5,2) NULL,
    weight_kg       DECIMAL(5,2) NULL,
    bmi             DECIMAL(5,2) NULL,
    step_goal       INT          NOT NULL DEFAULT 10000,
    calorie_goal    INT          NOT NULL DEFAULT 2000,
    water_goal_l    DECIMAL(4,2) NOT NULL DEFAULT 2.5,
    updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                                 ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_hp_user FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Daily Metrics ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS daily_metrics (
    id                 INT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id            INT          NOT NULL,
    metric_date        DATE         NOT NULL,
    steps              INT          NOT NULL DEFAULT 0,
    calories_burned    INT          NOT NULL DEFAULT 0,
    calories_consumed  INT          NOT NULL DEFAULT 0,
    water_intake_l     DECIMAL(4,2) NOT NULL DEFAULT 0.00,
    active_minutes     INT          NOT NULL DEFAULT 0,
    sleep_hours        DECIMAL(4,2) NULL,
    created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_date (user_id, metric_date),
    CONSTRAINT fk_dm_user FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Health Reports (uploaded files) ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS health_reports (
    id            INT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id       INT          NOT NULL,
    title         VARCHAR(255) NOT NULL,
    report_date   DATE         NULL,
    file_path     VARCHAR(500) NULL,
    file_type     VARCHAR(20)  NULL,   -- 'pdf', 'jpg', 'png'
    status        ENUM('pending','analyzed','failed') NOT NULL DEFAULT 'pending',
    ai_summary    TEXT         NULL,   -- Vijay's parsed notes
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_hr_user FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Report Metrics (key-value pairs extracted from reports) ───────────────
CREATE TABLE IF NOT EXISTS report_metrics (
    id          INT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    report_id   INT          NOT NULL,
    metric_name VARCHAR(120) NOT NULL,   -- e.g. 'Hemoglobin'
    metric_val  VARCHAR(120) NOT NULL,   -- e.g. '13.8 g/dL'
    CONSTRAINT fk_rm_report FOREIGN KEY (report_id) REFERENCES health_reports(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Clinical History (timeline entries) ───────────────────────────────────
CREATE TABLE IF NOT EXISTS clinical_history (
    id          INT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id     INT          NOT NULL,
    event_date  DATE         NOT NULL,
    title       VARCHAR(255) NOT NULL,
    summary     TEXT         NOT NULL,
    source      ENUM('manual','report','agent') NOT NULL DEFAULT 'manual',
    report_id   INT          NULL,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ch_user   FOREIGN KEY (user_id)   REFERENCES users(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_ch_report FOREIGN KEY (report_id) REFERENCES health_reports(id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Chat History ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS chat_history (
    id          INT      NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id     INT      NOT NULL,
    role        ENUM('user','assistant') NOT NULL,
    message     TEXT     NOT NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_chat_user FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Genetic Reports ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS genetic_reports (
    id              INT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id         INT          NOT NULL UNIQUE,
    report_ref      VARCHAR(60)  NULL,           -- e.g. DNL1000001
    raw_json        JSON         NULL,           -- full report data
    processed_at    DATETIME     NULL,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_gr_user FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Diet Plans ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS diet_plans (
    id           INT      NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id      INT      NOT NULL,
    week_start   DATE     NOT NULL,
    plan_json    JSON     NOT NULL,   -- full week plan
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_week (user_id, week_start),
    CONSTRAINT fk_dp_user FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Exercise Plans ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS exercise_plans (
    id           INT      NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id      INT      NOT NULL,
    week_start   DATE     NOT NULL,
    plan_json    JSON     NOT NULL,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_week_ex (user_id, week_start),
    CONSTRAINT fk_ep_user FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ══════════════════════════════════════════════════════════════════════════
--  Seed: demo user  (password = "password123")
-- ══════════════════════════════════════════════════════════════════════════
INSERT IGNORE INTO users (id, name, email, password_hash, plan) VALUES
(1, 'Rahul Kumar', 'rahul@example.com',
 '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewFdOHKxjchRPKfm', 'premium');

INSERT IGNORE INTO health_profiles
    (user_id, age, blood_group, height_cm, weight_kg, bmi, step_goal, calorie_goal, water_goal_l)
VALUES (1, 28, 'O+', 177.8, 72.0, 22.4, 10000, 2000, 2.5);

INSERT IGNORE INTO daily_metrics
    (user_id, metric_date, steps, calories_burned, calories_consumed, water_intake_l, active_minutes)
VALUES
  (1, CURDATE(),        8240, 420, 1840, 1.8, 45),
  (1, CURDATE() - 1,    9800, 510, 1920, 2.1, 60),
  (1, CURDATE() - 2,    6500, 310, 1750, 1.5, 30),
  (1, CURDATE() - 3,   10200, 560, 2010, 2.3, 75),
  (1, CURDATE() - 4,    8800, 460, 1880, 2.0, 50),
  (1, CURDATE() - 5,    4500, 220, 1600, 1.2, 20),
  (1, CURDATE() - 6,    7200, 380, 1810, 1.9, 40);

INSERT IGNORE INTO clinical_history (user_id, event_date, title, summary, source) VALUES
(1, '2026-03-15', 'Blood Test Report',
 'CBC normal. Hemoglobin 13.8 g/dL. Blood sugar within normal fasting range. Cholesterol optimal at 178 mg/dL. No medications required.',
 'report'),
(1, '2026-01-08', 'Full Body Checkup',
 'BP excellent at 118/76. BMI healthy. Vitamin D deficiency noted (28 ng/mL). Supplement D3 2000 IU daily recommended. Follow up in 3 months.',
 'report'),
(1, '2025-10-03', 'Dental Checkup',
 'No cavities. Minor plaque buildup. Advised professional cleaning every 6 months.',
 'manual'),
(1, '2025-07-20', 'Eye Examination',
 'Vision 6/6 both eyes. No correction required. No signs of strain or pressure issues.',
 'manual');

INSERT IGNORE INTO genetic_reports (user_id, report_ref, processed_at) VALUES
(1, 'DNL1000001', NOW());