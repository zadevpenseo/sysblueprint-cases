-- ======================================================
-- CASE 06: Enterprise Data Observability & Lineage Ledger
-- Dialek Target : PostgreSQL 15+ / ANSI SQL:1992
-- Integritas    : Silsilah Data, Audit Kualitas, dan Deteksi Drift
-- ======================================================

CREATE TABLE IF NOT EXISTS "raw_events" (
  "id" UUID PRIMARY KEY,
  "source_system" VARCHAR(64) NOT NULL,
  "payload" TEXT NOT NULL,
  "checksum" VARCHAR(64) NOT NULL,
  "ingested_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "dim_customers" (
  "customer_key" UUID PRIMARY KEY,
  "customer_id" VARCHAR(64) NOT NULL,
  "full_name" VARCHAR(128) NOT NULL,
  "tier" VARCHAR(32) NOT NULL DEFAULT 'STANDARD',
  "is_active" BOOLEAN NOT NULL DEFAULT TRUE,
  "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "uq_dim_customer_id" UNIQUE ("customer_id")
);

CREATE TABLE IF NOT EXISTS "fct_transactions" (
  "transaction_key" UUID PRIMARY KEY,
  "raw_event_id" UUID NOT NULL,
  "customer_key" UUID NOT NULL,
  "amount" NUMERIC(18,2) NOT NULL CHECK ("amount" >= 0),
  "transaction_type" VARCHAR(32) NOT NULL,
  "event_timestamp" TIMESTAMP WITH TIME ZONE NOT NULL,
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "fk_fct_raw_event" FOREIGN KEY ("raw_event_id") REFERENCES "raw_events" ("id") ON DELETE RESTRICT,
  CONSTRAINT "fk_fct_customer" FOREIGN KEY ("customer_key") REFERENCES "dim_customers" ("customer_key") ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS "lineage_audit_log" (
  "id" UUID PRIMARY KEY,
  "upstream_asset" VARCHAR(128) NOT NULL,
  "downstream_asset" VARCHAR(128) NOT NULL,
  "transformation_job" VARCHAR(128) NOT NULL,
  "records_processed" INTEGER NOT NULL CHECK ("records_processed" >= 0),
  "status" VARCHAR(32) NOT NULL DEFAULT 'COMPLETED',
  "executed_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "schema_drift_alerts" (
  "id" UUID PRIMARY KEY,
  "asset_name" VARCHAR(128) NOT NULL,
  "drift_type" VARCHAR(32) NOT NULL,
  "severity" VARCHAR(16) NOT NULL CHECK ("severity" IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
  "blast_radius_score" INTEGER NOT NULL CHECK ("blast_radius_score" BETWEEN 1 AND 100),
  "detected_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indeks performa penelusuran relasi silsilah data
CREATE INDEX IF NOT EXISTS "idx_fct_customer" ON "fct_transactions" ("customer_key");
CREATE INDEX IF NOT EXISTS "idx_fct_timestamp" ON "fct_transactions" ("event_timestamp");
CREATE INDEX IF NOT EXISTS "idx_lineage_downstream" ON "lineage_audit_log" ("downstream_asset", "executed_at");
