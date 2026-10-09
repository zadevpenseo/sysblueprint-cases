# Kamus Data: Multi-Tenant B2B SaaS Core

## 1. Tabel: `tenants`
Entitas organisasi atau perusahaan pelanggan yang menyewa layanan perangkat lunak.

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik penyewa. |
| `organization_slug` | `VARCHAR(64)` | NOT NULL, UNIQUE | Pengenal unik organisasi di URL (misal `acme-corp`). |
| `company_name` | `VARCHAR(128)` | NOT NULL | Nama resmi perusahaan. |
| `subscription_tier` | `VARCHAR(32)` | NOT NULL, DEFAULT 'FREE' | Paket langganan: FREE, PRO, ENTERPRISE. |
| `is_active` | `BOOLEAN` | NOT NULL, DEFAULT TRUE | Status operasional tenant. |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT NOW | Waktu pendaftaran organisasi. |

---

## 2. Tabel: `users`
Identitas akun manusia universal lintas penyewa.

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik pengguna. |
| `email` | `VARCHAR(128)` | NOT NULL, UNIQUE | Alamat surel unik untuk autentikasi. |
| `full_name` | `VARCHAR(128)` | NOT NULL | Nama lengkap pengguna. |
| `password_hash` | `VARCHAR(255)` | NOT NULL | Hash kata sandi terenkripsi (Argon2id/Bcrypt). |
| `is_verified` | `BOOLEAN` | NOT NULL, DEFAULT FALSE | Status verifikasi email. |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT NOW | Waktu pembuatan akun. |

---

## 3. Tabel: `tenant_memberships`
Tabel relasi many-to-many antara pengguna dan organisasi dengan kontrol peran (RBAC).

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik keanggotaan. |
| `tenant_id` | `UUID` | NOT NULL, FK -> `tenants.id` | Organisasi tempat anggota bernaung. |
| `user_id` | `UUID` | NOT NULL, FK -> `users.id` | Pengguna yang menjadi anggota. |
| `role` | `VARCHAR(32)` | NOT NULL, DEFAULT 'MEMBER' | Tingkat izin: OWNER, ADMIN, MEMBER, VIEWER. |
| `joined_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT NOW | Waktu bergabung ke organisasi. |

---

## 4. Tabel: `audit_logs`
Pencatatan riwayat aktivitas pengguna untuk kepatuhan SOC2 dan ISO 27001.

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik catatan audit. |
| `tenant_id` | `UUID` | NOT NULL, FK -> `tenants.id` | Organisasi tempat aksi berlangsung. |
| `user_id` | `UUID` | NULLABLE, FK -> `users.id` | Pelaku aksi (null jika aksi sistem otomatis). |
| `action` | `VARCHAR(64)` | NOT NULL | Nama aksi (misal `USER_INVITED`, `ROLE_CHANGED`). |
| `resource_type` | `VARCHAR(64)` | NOT NULL | Objek yang diubah (misal `MEMBERSHIP`, `SETTINGS`). |
| `ip_address` | `VARCHAR(45)` | NULLABLE | Alamat IP asal permintaan. |
| `payload` | `TEXT` | NULLABLE | Rincian nilai sebelum dan sesudah perubahan. |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT NOW | Waktu kejadian audit. |
