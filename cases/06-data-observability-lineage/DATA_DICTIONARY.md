# Kamus Data: Enterprise Data Observability & Lineage Ledger

Dokumen ini mendefinisikan struktur data, tipe field, batasan integritas, dan tujuan bisnis dari setiap entitas pada arsitektur observabilitas data.

---

### 1. Tabel: `raw_events`
Menyimpan muatan log peristiwa mentah yang diserap dari berbagai sistem produsen hulu (*upstream systems*).

| Nama Kolom | Tipe Data | Nullable | Default | Deskripsi Bisnis & Batasan |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | NO | None | Kunci primer unik setiap rekaman log mentah |
| `source_system` | VARCHAR(64) | NO | None | Identitas sistem pengirim (misal: POS, Mobile App, Webhook) |
| `payload` | TEXT | NO | None | Muatan data mentah terkompresi atau JSON string |
| `checksum` | VARCHAR(64) | NO | None | Hash SHA-256 muatan untuk pencegahan data duplikat |
| `ingested_at` | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Waktu saat rekaman pertama kali masuk ke landing bucket |

---

### 2. Tabel: `dim_customers`
Tabel dimensi yang memuat profil identitas entitas pelanggan terstandardisasi.

| Nama Kolom | Tipe Data | Nullable | Default | Deskripsi Bisnis & Batasan |
| :--- | :--- | :--- | :--- | :--- |
| `customer_key` | UUID | NO | None | Kunci pengganti (*surrogate key*) unik dimensi pelanggan |
| `customer_id` | VARCHAR(64) | NO | None | ID bisnis pelanggan dari sistem sumber (Unique Constraint) |
| `full_name` | VARCHAR(128) | NO | None | Nama lengkap terverifikasi pelanggan |
| `tier` | VARCHAR(32) | NO | 'STANDARD' | Tingkat keanggotaan pelanggan (STANDARD, GOLD, PLATINUM) |
| `is_active` | BOOLEAN | NO | TRUE | Status aktif atau penonaktifan akun pelanggan |
| `updated_at` | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Waktu pembaruan profil dimensi terakhir |

---

### 3. Tabel: `fct_transactions`
Tabel fakta granular yang mencatat mutasi transaksi finansial bisnis dengan referensi relasional ketat.

| Nama Kolom | Tipe Data | Nullable | Default | Deskripsi Bisnis & Batasan |
| :--- | :--- | :--- | :--- | :--- |
| `transaction_key` | UUID | NO | None | Kunci primer transaksi |
| `raw_event_id` | UUID | NO | None | Kunci asing ke rekaman log hulu `raw_events` |
| `customer_key` | UUID | NO | None | Kunci asing ke entitas dimensi `dim_customers` |
| `amount` | NUMERIC(18,2) | NO | None | Nilai nominal transaksi (Check Constraint: >= 0) |
| `transaction_type` | VARCHAR(32) | NO | None | Kategori mutasi (PURCHASE, REFUND, TOPUP) |
| `event_timestamp` | TIMESTAMPTZ | NO | None | Waktu kejadian transaksi riil di sisi pengguna |
| `created_at` | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Waktu transaksi dimuat ke dalam data mart |

---

### 4. Tabel: `lineage_audit_log`
Buku besar operasional silsilah data yang mencatat eksekusi transformasi antar-aset data (*edge lineage*).

| Nama Kolom | Tipe Data | Nullable | Default | Deskripsi Bisnis & Batasan |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | NO | None | Kunci primer unik catatan silsilah |
| `upstream_asset` | VARCHAR(128) | NO | None | Nama tabel atau topik sumber asal (hulu) |
| `downstream_asset` | VARCHAR(128) | NO | None | Nama tabel atau dashboard tujuan (hilir) |
| `transformation_job` | VARCHAR(128) | NO | None | Nama job dbt, Spark, atau pipa ETL yang bertanggung jawab |
| `records_processed` | INTEGER | NO | None | Jumlah baris data yang diproses (Check: >= 0) |
| `status` | VARCHAR(32) | NO | 'COMPLETED' | Status penyelesaian pipa (COMPLETED, FAILED, WARN) |
| `executed_at` | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Waktu pencatatan eksekusi hubungan silsilah data |

---

### 5. Tabel: `schema_drift_alerts`
Pencatatan peringatan otomatis ketika terjadi anomali skema atau pergeseran struktur tabel pada sistem hilir.

| Nama Kolom | Tipe Data | Nullable | Default | Deskripsi Bisnis & Batasan |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | NO | None | Kunci unik catatan insiden kualitas data |
| `asset_name` | VARCHAR(128) | NO | None | Nama tabel yang mengalami perubahan tak terencana |
| `drift_type` | VARCHAR(32) | NO | None | Tipe pergeseran (COLUMN_DROPPED, TYPE_CHANGED, NULLABILITY) |
| `severity` | VARCHAR(16) | NO | None | Tingkat keparahan (LOW, MEDIUM, HIGH, CRITICAL) |
| `blast_radius_score` | INTEGER | NO | None | Nilai dampak ke model analitik hilir (1 hingga 100) |
| `detected_at` | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Waktu pendeteksian anomali oleh validator observabilitas |
