# Kamus Data: Hospital Electronic Medical Record (EMR)

## 1. Tabel: `patients`
Basis data induk pasien rumah sakit.

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik sistem pasien. |
| `medical_record_number` | `VARCHAR(32)` | NOT NULL, UNIQUE | Nomor Rekam Medis (Nomor RM) fisik resmi. |
| `full_name` | `VARCHAR(128)` | NOT NULL | Nama lengkap pasien sesuai kartu identitas. |
| `date_of_birth` | `DATE` | NOT NULL | Tanggal lahir untuk perhitungan umur klinis. |
| `gender` | `CHAR(1)` | NOT NULL, CHECK ('M', 'F') | Jenis kelamin biologis pasien. |
| `blood_type` | `VARCHAR(4)` | NULLABLE | Golongan darah dan rhesus (misal `O+`, `AB-`). |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT NOW | Waktu pendaftaran pertama pasien. |

---

## 2. Tabel: `practitioners`
Tenaga medis bersertifikat (dokter spesialis, dokter umum, perawat).

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik tenaga medis. |
| `license_number` | `VARCHAR(64)` | NOT NULL, UNIQUE | Nomor Surat Tanda Registrasi (STR) resmi. |
| `full_name` | `VARCHAR(128)` | NOT NULL | Nama tenaga medis dan gelar profesional. |
| `specialty` | `VARCHAR(64)` | NOT NULL | Bidang spesialisasi medis (misal Kardiologi). |
| `is_active` | `BOOLEAN` | NOT NULL, DEFAULT TRUE | Status izin praktik aktif di rumah sakit. |

---

## 3. Tabel: `encounters`
Kunjungan atau episode perawatan pasien di poliklinik atau ruang rawat.

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik kunjungan rawat. |
| `patient_id` | `UUID` | NOT NULL, FK -> `patients.id` | Pasien yang dirawat. |
| `practitioner_id` | `UUID` | NOT NULL, FK -> `practitioners.id` | Dokter Penanggung Jawab Pelayanan (DPJP). |
| `admission_time` | `TIMESTAMPTZ` | NOT NULL | Waktu kedatangan / pendaftaran rawat. |
| `discharge_time` | `TIMESTAMPTZ` | NULLABLE | Waktu pasien dipulangkan. |
| `encounter_type` | `VARCHAR(32)` | NOT NULL | Jenis: OUTPATIENT, INPATIENT, EMERGENCY. |
| `encounter_status` | `VARCHAR(32)` | NOT NULL, DEFAULT 'ARRIVED'| Status: ARRIVED, IN_PROGRESS, COMPLETED. |

---

## 4. Tabel: `clinical_notes`
Catatan rekam medis terperinci dengan format standar SOAP (Subjective, Objective, Assessment, Plan).

| Kolom | Tipe Data | Kendala (*Constraints*) | Deskripsi Bisnis |
|:---|:---|:---|:---|
| `id` | `UUID` | PRIMARY KEY | Identifikator unik catatan rekam medis. |
| `encounter_id` | `UUID` | NOT NULL, FK -> `encounters.id` | Kunjungan rawat terkait. |
| `author_id` | `UUID` | NOT NULL, FK -> `practitioners.id` | Dokter/perawat yang menulis catatan. |
| `note_type` | `VARCHAR(32)` | NOT NULL | Jenis catatan: SOAP_NOTE, LAB_RESULT, DISCHARGE. |
| `subjective` | `TEXT` | NULLABLE | Keluhan dan anamnesis pasien. |
| `objective` | `TEXT` | NULLABLE | Hasil pemeriksaan fisik dan tanda vital. |
| `assessment` | `TEXT` | NULLABLE | Diagnosis kerja atau diagnosis banding (ICD-10). |
| `plan` | `TEXT` | NULLABLE | Rencana terapi, obat, dan tindakan lanjut. |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT NOW | Waktu stempel catatan rekam medis. |
