# Kamus Data: E-Commerce Flash-Sale Inventory

## 1. Tabel: `products`
Katalog barang dan ketersediaan stok fisik gudang.

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik produk. |
| `sku` | `VARCHAR(64)` | NOT NULL, UNIQUE | Kode unik stok unit barang. |
| `title` | `VARCHAR(255)` | NOT NULL | Judul/nama produk di etalase. |
| `price` | `NUMERIC(12,2)` | NOT NULL, CHECK (price >= 0) | Harga jual satuan saat ini. |
| `stock_quantity` | `INTEGER` | NOT NULL, CHECK (stock_quantity >= 0) | Total stok fisik di gudang. |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT NOW | Waktu pendaftaran barang. |

---

## 2. Tabel: `orders`
Transaksi pesanan belanja dari pelanggan.

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik pesanan. |
| `order_number` | `VARCHAR(64)` | NOT NULL, UNIQUE | Nomor invoice belanja yang ramah pengguna. |
| `customer_id` | `UUID` | NOT NULL | Identifikator pembeli. |
| `total_amount` | `NUMERIC(12,2)` | NOT NULL, CHECK (total_amount >= 0) | Total tagihan belanja. |
| `order_status` | `VARCHAR(32)` | NOT NULL, DEFAULT 'PENDING' | Status: PENDING, PAID, CANCELLED, SHIPPED. |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT NOW | Waktu pesanan diajukan. |

---

## 3. Tabel: `stock_reservations`
Pencatatan alokasi stok sementara untuk mencegah *overselling* saat flash sale.

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik reservasi. |
| `order_id` | `UUID` | NOT NULL, FK -> `orders.id` | Pesanan yang menahan stok. |
| `product_id` | `UUID` | NOT NULL, FK -> `products.id` | Barang yang dialokasikan. |
| `reserved_quantity` | `INTEGER` | NOT NULL, CHECK (> 0) | Jumlah unit yang ditahan sementara. |
| `status` | `VARCHAR(20)` | NOT NULL, DEFAULT 'ACTIVE' | Status: ACTIVE, COMMITTED (bayar), EXPIRED. |
| `expires_at` | `TIMESTAMPTZ` | NOT NULL | Batas waktu checkout (misal 15 menit). |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT NOW | Waktu kunci reservasi dimulai. |
