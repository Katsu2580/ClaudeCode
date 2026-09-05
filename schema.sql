CREATE TABLE IF NOT EXISTS responses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nickname TEXT NOT NULL,
  satisfaction INTEGER NOT NULL,
  comment TEXT,
  created_at TEXT NOT NULL
);
