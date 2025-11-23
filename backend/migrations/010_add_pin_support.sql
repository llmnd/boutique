-- Add PIN support to owners table
ALTER TABLE owners ADD COLUMN IF NOT EXISTS pin VARCHAR(4);
