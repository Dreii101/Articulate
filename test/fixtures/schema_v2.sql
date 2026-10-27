-- Pre-release Phase 2 core schema fixture. Phase 1 had no database.
PRAGMA user_version = 2;
CREATE TABLE practice_sessions (
  id TEXT NOT NULL PRIMARY KEY,
  exercise_id TEXT NOT NULL,
  exercise_version INTEGER NOT NULL,
  module_id TEXT NOT NULL,
  snapshot TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('draft','running','paused','interrupted','completed','abandoned')),
  stage TEXT NOT NULL CHECK (stage IN ('prepare','respond','reflect')),
  created_utc_ms INTEGER NOT NULL,
  updated_utc_ms INTEGER NOT NULL,
  started_utc_ms INTEGER,
  completed_utc_ms INTEGER,
  local_practice_date TEXT NOT NULL,
  original_offset_minutes INTEGER NOT NULL
);
CREATE TABLE responses (
  id TEXT NOT NULL PRIMARY KEY,
  session_id TEXT NOT NULL UNIQUE REFERENCES practice_sessions(id),
  body TEXT NOT NULL DEFAULT '',
  updated_utc_ms INTEGER NOT NULL
);
CREATE TABLE timing_segments (
  id TEXT NOT NULL PRIMARY KEY,
  session_id TEXT NOT NULL REFERENCES practice_sessions(id),
  stage TEXT NOT NULL,
  started_utc_ms INTEGER NOT NULL,
  checkpoint_utc_ms INTEGER NOT NULL,
  ended_utc_ms INTEGER,
  elapsed_ms INTEGER NOT NULL CHECK (elapsed_ms >= 0),
  end_reason TEXT
);

CREATE TABLE review_records (
 id TEXT NOT NULL PRIMARY KEY,
 session_id TEXT NOT NULL UNIQUE REFERENCES practice_sessions(id),
 status TEXT NOT NULL CHECK (status IN ('inProgress','reviewed')),
 notes TEXT NOT NULL,
 updated_utc_ms INTEGER NOT NULL
);
CREATE TABLE app_settings (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL);
