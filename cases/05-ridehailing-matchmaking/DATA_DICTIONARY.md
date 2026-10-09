# Kamus Data: On-Demand Ride-Hailing Matchmaking

## 1. Tabel: `riders`
Basis data pelanggan penumpang transportasi online.

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik penumpang. |
| `phone_number` | `VARCHAR(20)` | NOT NULL, UNIQUE | Nomor telepon seluler untuk kontak penjemputan. |
| `full_name` | `VARCHAR(128)` | NOT NULL | Nama penumpang. |
| `rating_score` | `NUMERIC(3,2)` | NOT NULL, DEFAULT 5.00 | Skor reputasi penumpang (1.00 - 5.00). |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT NOW | Waktu pendaftaran akun. |

---

## 2. Tabel: `drivers`
Mitra pengemudi transportasi online.

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik pengemudi. |
| `license_plate` | `VARCHAR(16)` | NOT NULL, UNIQUE | Nomor plat kendaraan bermotor terdaftar. |
| `full_name` | `VARCHAR(128)` | NOT NULL | Nama resmi mitra pengemudi. |
| `vehicle_type` | `VARCHAR(16)` | NOT NULL | Jenis armada: MOTORBIKE, CAR_4SEATER, CAR_6SEATER. |
| `is_online` | `BOOLEAN` | NOT NULL, DEFAULT FALSE | Ketersediaan menerima pesanan saat ini. |
| `current_latitude` | `NUMERIC(9,6)` | NULLABLE | Posisi lintang GPS terkini pengemudi. |
| `current_longitude`| `NUMERIC(9,6)` | NULLABLE | Posisi bujur GPS terkini pengemudi. |
| `rating_score` | `NUMERIC(3,2)` | NOT NULL, DEFAULT 5.00 | Skor ulasan dari penumpang. |

---

## 3. Tabel: `trips`
Perjalanan pemesanan transportasi dari penjemputan hingga tiba di tujuan.

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik perjalanan. |
| `rider_id` | `UUID` | NOT NULL, FK -> `riders.id` | Penumpang pemesan. |
| `driver_id` | `UUID` | NULLABLE, FK -> `drivers.id` | Pengemudi yang mengantar (null saat pencarian). |
| `origin_latitude` | `NUMERIC(9,6)` | NOT NULL | Titik jemput GPS lintang. |
| `origin_longitude`| `NUMERIC(9,6)` | NOT NULL | Titik jemput GPS bujur. |
| `destination_latitude` | `NUMERIC(9,6)` | NOT NULL | Titik tujuan GPS lintang. |
| `destination_longitude`| `NUMERIC(9,6)` | NOT NULL | Titik tujuan GPS bujur. |
| `fare_amount` | `NUMERIC(10,2)` | NOT NULL, CHECK (>= 0) | Tarif ongkos perjalanan. |
| `trip_status` | `VARCHAR(32)` | NOT NULL, DEFAULT 'REQUESTED'| Status alur perjalanan. |
| `requested_at`| `TIMESTAMPTZ` | NOT NULL, DEFAULT NOW | Waktu pesanan diajukan. |
| `completed_at`| `TIMESTAMPTZ` | NULLABLE | Waktu perjalanan selesai/dibatalkan. |

---

## 4. Tabel: `trip_status_logs`
Catatan audit perubahan status perjalanan per detik untuk resolusi keluhan.

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik catatan log status. |
| `trip_id` | `UUID` | NOT NULL, FK -> `trips.id` | Perjalanan terkait. |
| `previous_status` | `VARCHAR(32)` | NULLABLE | Status sebelum transisi. |
| `new_status` | `VARCHAR(32)` | NOT NULL | Status sesudah transisi. |
| `trigger_source` | `VARCHAR(32)` | NOT NULL | Pemicu: SYSTEM, DRIVER, RIDER. |
| `recorded_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT NOW | Waktu stempel transisi status. |
