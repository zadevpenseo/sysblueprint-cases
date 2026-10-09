-- ======================================================
-- CASE 04: Hospital Electronic Medical Record (EMR)
-- Dialek Target : PostgreSQL 15+ / ANSI SQL:1992
-- Integritas    : Rekam Klinis Tak Terubah & Kepatuhan Audit HIPAA/Permenkes
-- ======================================================

CREATE TABLE IF NOT EXISTS "patients" (
  "id" UUID PRIMARY KEY,
  "medical_record_number" VARCHAR(32) NOT NULL,
  "full_name" VARCHAR(128) NOT NULL,
  "date_of_birth" DATE NOT NULL,
  "gender" CHAR(1) NOT NULL CHECK ("gender" IN ('M', 'F')),
  "blood_type" VARCHAR(4),
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "uq_patient_mrn" UNIQUE ("medical_record_number")
);

CREATE TABLE IF NOT EXISTS "practitioners" (
  "id" UUID PRIMARY KEY,
  "license_number" VARCHAR(64) NOT NULL,
  "full_name" VARCHAR(128) NOT NULL,
  "specialty" VARCHAR(64) NOT NULL,
  "is_active" BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT "uq_practitioner_license" UNIQUE ("license_number")
);

CREATE TABLE IF NOT EXISTS "encounters" (
  "id" UUID PRIMARY KEY,
  "patient_id" UUID NOT NULL,
  "practitioner_id" UUID NOT NULL,
  "admission_time" TIMESTAMP WITH TIME ZONE NOT NULL,
  "discharge_time" TIMESTAMP WITH TIME ZONE,
  "encounter_type" VARCHAR(32) NOT NULL DEFAULT 'OUTPATIENT', -- OUTPATIENT, INPATIENT, EMERGENCY
  "encounter_status" VARCHAR(32) NOT NULL DEFAULT 'ARRIVED', -- ARRIVED, IN_PROGRESS, COMPLETED, CANCELLED
  CONSTRAINT "fk_encounter_patient" FOREIGN KEY ("patient_id") REFERENCES "patients" ("id") ON DELETE RESTRICT,
  CONSTRAINT "fk_encounter_practitioner" FOREIGN KEY ("practitioner_id") REFERENCES "practitioners" ("id") ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS "clinical_notes" (
  "id" UUID PRIMARY KEY,
  "encounter_id" UUID NOT NULL,
  "author_id" UUID NOT NULL,
  "note_type" VARCHAR(32) NOT NULL, -- SOAP_NOTE, LAB_RESULT, DISCHARGE_SUMMARY
  "subjective" TEXT,
  "objective" TEXT,
  "assessment" TEXT,
  "plan" TEXT,
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "fk_note_encounter" FOREIGN KEY ("encounter_id") REFERENCES "encounters" ("id") ON DELETE RESTRICT,
  CONSTRAINT "fk_note_author" FOREIGN KEY ("author_id") REFERENCES "practitioners" ("id") ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS "idx_encounters_patient" ON "encounters" ("patient_id");
CREATE INDEX IF NOT EXISTS "idx_clinical_notes_encounter" ON "clinical_notes" ("encounter_id");
