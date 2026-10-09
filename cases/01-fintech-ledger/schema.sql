-- ======================================================
-- CASE 01: Double-Entry Financial Ledger
-- Dialek Target : PostgreSQL 15+ / ANSI SQL:1992
-- Integritas    : Immutable Jurnal & Prinsip Debit-Kredit Seimbang
-- ======================================================

CREATE TABLE IF NOT EXISTS "accounts" (
  "id" UUID PRIMARY KEY,
  "account_code" VARCHAR(32) NOT NULL,
  "account_name" VARCHAR(128) NOT NULL,
  "account_type" VARCHAR(16) NOT NULL, -- ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE
  "currency" CHAR(3) NOT NULL DEFAULT 'IDR',
  "is_active" BOOLEAN NOT NULL DEFAULT TRUE,
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "uq_account_code" UNIQUE ("account_code")
);

CREATE TABLE IF NOT EXISTS "journal_entries" (
  "id" UUID PRIMARY KEY,
  "reference_number" VARCHAR(64) NOT NULL,
  "transaction_date" TIMESTAMP WITH TIME ZONE NOT NULL,
  "description" TEXT NOT NULL,
  "is_posted" BOOLEAN NOT NULL DEFAULT FALSE,
  "posted_at" TIMESTAMP WITH TIME ZONE,
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "uq_journal_reference" UNIQUE ("reference_number")
);

CREATE TABLE IF NOT EXISTS "journal_lines" (
  "id" UUID PRIMARY KEY,
  "entry_id" UUID NOT NULL,
  "account_id" UUID NOT NULL,
  "amount" NUMERIC(18,4) NOT NULL CHECK ("amount" > 0),
  "entry_direction" VARCHAR(6) NOT NULL CHECK ("entry_direction" IN ('DEBIT', 'CREDIT')),
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "fk_journal_lines_entry" FOREIGN KEY ("entry_id") REFERENCES "journal_entries" ("id") ON DELETE RESTRICT,
  CONSTRAINT "fk_journal_lines_account" FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE RESTRICT
);

-- Indeks performa pencarian mutasi akun
CREATE INDEX IF NOT EXISTS "idx_lines_account_created" ON "journal_lines" ("account_id", "created_at");
CREATE INDEX IF NOT EXISTS "idx_lines_entry" ON "journal_lines" ("entry_id");
