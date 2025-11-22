-- Migration: Add boutique mode setting
-- Adds boutique_mode_enabled to owners table to persist boutique mode preference

BEGIN;

-- Add boutique_mode_enabled to owners table
ALTER TABLE owners 
ADD COLUMN IF NOT EXISTS boutique_mode_enabled BOOLEAN DEFAULT FALSE;

COMMIT;
