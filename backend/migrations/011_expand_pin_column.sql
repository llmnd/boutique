-- Expand PIN column to store hashed PINs (bcrypt produces ~60 char hashes)
ALTER TABLE owners ALTER COLUMN pin TYPE VARCHAR(255);
