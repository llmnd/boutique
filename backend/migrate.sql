-- Migration: add clients and payments tables, add client_id to debts
CREATE TABLE IF NOT EXISTS clients (
  id SERIAL PRIMARY KEY,
  client_number TEXT UNIQUE,
  name TEXT NOT NULL,
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payments (
  id SERIAL PRIMARY KEY,
  debt_id INTEGER REFERENCES debts(id) ON DELETE CASCADE,
  amount NUMERIC(12,2) NOT NULL,
  paid_at TIMESTAMP NOT NULL,
  notes TEXT
);

-- Add client_id to debts if not present
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='debts' AND column_name='client_id') THEN
    ALTER TABLE debts ADD COLUMN client_id INTEGER REFERENCES clients(id);
  END IF;
END$$;

-- Add paid and paid_at if missing (safe no-op if already exists)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='debts' AND column_name='paid') THEN
    ALTER TABLE debts ADD COLUMN paid BOOLEAN DEFAULT FALSE;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='debts' AND column_name='paid_at') THEN
    ALTER TABLE debts ADD COLUMN paid_at TIMESTAMP;
  END IF;
END$$;

-- Create index to speed up lookups
CREATE INDEX IF NOT EXISTS idx_debts_client_id ON debts(client_id);
ALTER TABLE debts ADD COLUMN IF NOT EXISTS paid BOOLEAN DEFAULT FALSE; 
ALTER TABLE debts ADD COLUMN IF NOT EXISTS paid_at TIMESTAMP; 
