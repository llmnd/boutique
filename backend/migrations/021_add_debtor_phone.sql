-- Migration 021: Ajouter debtor_phone pour tracer qui doit l'argent
-- Objectif: Quand une dette est créée pour quelqu'un d'autre (via SMS),
-- on sait qui la reçoit même s'il n'est pas un "client" du créancier

ALTER TABLE debts ADD COLUMN IF NOT EXISTS debtor_phone TEXT;

-- Indexer pour les recherches rapides
CREATE INDEX IF NOT EXISTS idx_debts_debtor_phone ON debts(debtor_phone);

-- Ajouter un commentaire pour expliquer
COMMENT ON COLUMN debts.debtor_phone IS 'Phone number of person who owes (debtor), used when debt is created for someone who is not a registered client';
