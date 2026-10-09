-- ======================================================
-- CASE 02: E-Commerce Flash-Sale Inventory & Orders
-- Dialek Target : PostgreSQL 15+ / ANSI SQL:1992
-- Integritas    : Reservasi Stok Idempoten & Penanganan Lonjakan Transaksi
-- ======================================================

CREATE TABLE IF NOT EXISTS "products" (
  "id" UUID PRIMARY KEY,
  "sku" VARCHAR(64) NOT NULL,
  "title" VARCHAR(255) NOT NULL,
  "price" NUMERIC(12,2) NOT NULL CHECK ("price" >= 0),
  "stock_quantity" INTEGER NOT NULL CHECK ("stock_quantity" >= 0),
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "uq_product_sku" UNIQUE ("sku")
);

CREATE TABLE IF NOT EXISTS "orders" (
  "id" UUID PRIMARY KEY,
  "order_number" VARCHAR(64) NOT NULL,
  "customer_id" UUID NOT NULL,
  "total_amount" NUMERIC(12,2) NOT NULL CHECK ("total_amount" >= 0),
  "order_status" VARCHAR(32) NOT NULL DEFAULT 'PENDING',
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "uq_order_number" UNIQUE ("order_number")
);

CREATE TABLE IF NOT EXISTS "order_items" (
  "id" UUID PRIMARY KEY,
  "order_id" UUID NOT NULL,
  "product_id" UUID NOT NULL,
  "quantity" INTEGER NOT NULL CHECK ("quantity" > 0),
  "unit_price" NUMERIC(12,2) NOT NULL CHECK ("unit_price" >= 0),
  CONSTRAINT "fk_order_items_order" FOREIGN KEY ("order_id") REFERENCES "orders" ("id") ON DELETE CASCADE,
  CONSTRAINT "fk_order_items_product" FOREIGN KEY ("product_id") REFERENCES "products" ("id") ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS "stock_reservations" (
  "id" UUID PRIMARY KEY,
  "order_id" UUID NOT NULL,
  "product_id" UUID NOT NULL,
  "reserved_quantity" INTEGER NOT NULL CHECK ("reserved_quantity" > 0),
  "status" VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, COMMITTED, EXPIRED
  "expires_at" TIMESTAMP WITH TIME ZONE NOT NULL,
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "fk_reservation_order" FOREIGN KEY ("order_id") REFERENCES "orders" ("id") ON DELETE CASCADE,
  CONSTRAINT "fk_reservation_product" FOREIGN KEY ("product_id") REFERENCES "products" ("id") ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS "idx_reservations_product_status" ON "stock_reservations" ("product_id", "status");
CREATE INDEX IF NOT EXISTS "idx_orders_customer" ON "orders" ("customer_id");
