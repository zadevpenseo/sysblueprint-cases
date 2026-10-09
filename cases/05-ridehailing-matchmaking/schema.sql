-- ======================================================
-- CASE 05: On-Demand Ride-Hailing Matchmaking
-- Dialek Target : PostgreSQL 15+ / ANSI SQL:1992
-- Integritas    : Alur Status Penugasan Pengemudi & Titik Lokasi Geospasial
-- ======================================================

CREATE TABLE IF NOT EXISTS "riders" (
  "id" UUID PRIMARY KEY,
  "phone_number" VARCHAR(20) NOT NULL,
  "full_name" VARCHAR(128) NOT NULL,
  "rating_score" NUMERIC(3,2) NOT NULL DEFAULT 5.00 CHECK ("rating_score" BETWEEN 1.00 AND 5.00),
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "uq_rider_phone" UNIQUE ("phone_number")
);

CREATE TABLE IF NOT EXISTS "drivers" (
  "id" UUID PRIMARY KEY,
  "license_plate" VARCHAR(16) NOT NULL,
  "full_name" VARCHAR(128) NOT NULL,
  "vehicle_type" VARCHAR(16) NOT NULL DEFAULT 'MOTORBIKE', -- MOTORBIKE, CAR_4SEATER, CAR_6SEATER
  "is_online" BOOLEAN NOT NULL DEFAULT FALSE,
  "current_latitude" NUMERIC(9,6),
  "current_longitude" NUMERIC(9,6),
  "rating_score" NUMERIC(3,2) NOT NULL DEFAULT 5.00 CHECK ("rating_score" BETWEEN 1.00 AND 5.00),
  CONSTRAINT "uq_driver_plate" UNIQUE ("license_plate")
);

CREATE TABLE IF NOT EXISTS "trips" (
  "id" UUID PRIMARY KEY,
  "rider_id" UUID NOT NULL,
  "driver_id" UUID,
  "origin_latitude" NUMERIC(9,6) NOT NULL,
  "origin_longitude" NUMERIC(9,6) NOT NULL,
  "destination_latitude" NUMERIC(9,6) NOT NULL,
  "destination_longitude" NUMERIC(9,6) NOT NULL,
  "fare_amount" NUMERIC(10,2) NOT NULL CHECK ("fare_amount" >= 0),
  "trip_status" VARCHAR(32) NOT NULL DEFAULT 'REQUESTED', 
  -- REQUESTED, SEARCHING_DRIVER, ACCEPTED, PICKING_UP, ON_TRIP, COMPLETED, CANCELLED
  "requested_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "completed_at" TIMESTAMP WITH TIME ZONE,
  CONSTRAINT "fk_trip_rider" FOREIGN KEY ("rider_id") REFERENCES "riders" ("id") ON DELETE RESTRICT,
  CONSTRAINT "fk_trip_driver" FOREIGN KEY ("driver_id") REFERENCES "drivers" ("id") ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS "trip_status_logs" (
  "id" UUID PRIMARY KEY,
  "trip_id" UUID NOT NULL,
  "previous_status" VARCHAR(32),
  "new_status" VARCHAR(32) NOT NULL,
  "trigger_source" VARCHAR(32) NOT NULL, -- SYSTEM, DRIVER, RIDER
  "recorded_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "fk_log_trip" FOREIGN KEY ("trip_id") REFERENCES "trips" ("id") ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS "idx_trips_rider_status" ON "trips" ("rider_id", "trip_status");
CREATE INDEX IF NOT EXISTS "idx_drivers_location" ON "drivers" ("is_online", "current_latitude", "current_longitude");
