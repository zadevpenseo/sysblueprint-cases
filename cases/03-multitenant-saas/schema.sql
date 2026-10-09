-- ======================================================
-- CASE 03: Multi-Tenant B2B SaaS Core
-- Dialek Target : PostgreSQL 15+ / ANSI SQL:1992
-- Integritas    : Isolasi Data Organisasi & RBAC (Role-Based Access Control)
-- ======================================================

CREATE TABLE IF NOT EXISTS "tenants" (
  "id" UUID PRIMARY KEY,
  "organization_slug" VARCHAR(64) NOT NULL,
  "company_name" VARCHAR(128) NOT NULL,
  "subscription_tier" VARCHAR(32) NOT NULL DEFAULT 'FREE',
  "is_active" BOOLEAN NOT NULL DEFAULT TRUE,
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "uq_tenant_slug" UNIQUE ("organization_slug")
);

CREATE TABLE IF NOT EXISTS "users" (
  "id" UUID PRIMARY KEY,
  "email" VARCHAR(128) NOT NULL,
  "full_name" VARCHAR(128) NOT NULL,
  "password_hash" VARCHAR(255) NOT NULL,
  "is_verified" BOOLEAN NOT NULL DEFAULT FALSE,
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "uq_user_email" UNIQUE ("email")
);

CREATE TABLE IF NOT EXISTS "tenant_memberships" (
  "id" UUID PRIMARY KEY,
  "tenant_id" UUID NOT NULL,
  "user_id" UUID NOT NULL,
  "role" VARCHAR(32) NOT NULL DEFAULT 'MEMBER', -- OWNER, ADMIN, MEMBER, VIEWER
  "joined_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "fk_member_tenant" FOREIGN KEY ("tenant_id") REFERENCES "tenants" ("id") ON DELETE CASCADE,
  CONSTRAINT "fk_member_user" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE,
  CONSTRAINT "uq_tenant_user_membership" UNIQUE ("tenant_id", "user_id")
);

CREATE TABLE IF NOT EXISTS "audit_logs" (
  "id" UUID PRIMARY KEY,
  "tenant_id" UUID NOT NULL,
  "user_id" UUID,
  "action" VARCHAR(64) NOT NULL,
  "resource_type" VARCHAR(64) NOT NULL,
  "ip_address" VARCHAR(45),
  "payload" TEXT,
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "fk_audit_tenant" FOREIGN KEY ("tenant_id") REFERENCES "tenants" ("id") ON DELETE CASCADE,
  CONSTRAINT "fk_audit_user" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS "idx_memberships_tenant" ON "tenant_memberships" ("tenant_id");
CREATE INDEX IF NOT EXISTS "idx_audit_tenant_time" ON "audit_logs" ("tenant_id", "created_at");
