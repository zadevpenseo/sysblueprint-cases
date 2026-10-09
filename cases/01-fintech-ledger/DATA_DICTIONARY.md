# Kamus Data: Double-Entry Financial Ledger

## 1. Tabel: `accounts`
Menyimpan bagan akun standar (Chart of Accounts / COA) untuk entitas bisnis.

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik akun. |
| `account_code` | `VARCHAR(32)` | NOT NULL, UNIQUE | Kode akun akuntansi (misal `1010` Kas, `2010` Hutang Usaha). |
| `account_name` | `VARCHAR(128)` | NOT NULL | Nama deskriptif akun. |
| `account_type` | `VARCHAR(16)` | NOT NULL | Klasifikasi standar: ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE. |
| `currency` | `CHAR(3)` | NOT NULL, DEFAULT 'IDR' | Kode mata uang ISO 4217. |
| `is_active` | `BOOLEAN` | NOT NULL, DEFAULT TRUE | Status keaktifan akun untuk transaksi baru. |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT NOW | Waktu pendaftaran akun ke sistem. |

---

## 2. Tabel: `journal_entries`
Header transaksi finansial yang mencatat konteks dan waktu terjadinya mutasi keuangan.

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik jurnal. |
| `reference_number` | `VARCHAR(64)` | NOT NULL, UNIQUE | Nomor referensi dokumen sumber (nomor faktur, bukti transfer). |
| `transaction_date` | `TIMESTAMPTZ` | NOT NULL | Tanggal efektif pembukuan transaksi. |
| `description` | `TEXT` | NOT NULL | Narasi atau memo pendukung transaksi. |
| `is_posted` | `BOOLEAN` | NOT NULL, DEFAULT FALSE | Menandai apakah jurnal telah dikunci dan tidak dapat diubah lagi. |
| `posted_at` | `TIMESTAMPTZ` | NULLABLE | Waktu saat jurnal difinalisasi/dibukukan. |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT NOW | Waktu entri jurnal pertama kali dibuat. |

---

## 3. Tabel: `journal_lines`
Baris mutasi terperinci yang mencatat aliran debit dan kredit.

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik baris jurnal. |
| `entry_id` | `UUID` | NOT NULL, FK -> `journal_entries.id` | Menghubungkan baris dengan header jurnal. |
| `account_id` | `UUID` | NOT NULL, FK -> `accounts.id` | Akun yang mengalami penambahan/pengurangan saldo. |
| `amount` | `NUMERIC(18,4)` | NOT NULL, CHECK (amount > 0) | Nilai nominal transaksi (presisi tinggi 4 desimal). |
| `entry_direction` | `VARCHAR(6)` | NOT NULL, CHECK ('DEBIT', 'CREDIT') | Arah mutasi akuntansi. |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT NOW | Waktu baris transaksi direkam. |
