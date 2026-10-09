# ADR-004: Rekam Medis Klinis Tak Terubah (*Append-Only SOAP Notes*)

## Status
Diterima (*Accepted*)

## Konteks
Sesuai regulasi hukum kesehatan (Permenkes RI No 24 Tahun 2022 tentang Rekam Medis dan standar internasional HIPAA), rekam medis pasien adalah dokumen hukum yang tidak boleh dihapus atau ditimpa sewenang-wenang. Jika dokter melakukan kesalahan ketik atau diagnosa tambahan, perubahan tidak boleh menghapus data lama, melainkan harus berupa adendum atau catatan koreksi terpisah.

## Keputusan
Kami memutuskan untuk:
1. Menjadikan tabel `clinical_notes` bersifat *append-only* (hanya tambah, tanpa pembaruan atau penghapusan):
   - Menerapkan hak akses basis data `REVOKE UPDATE, DELETE ON clinical_notes`.
2. Setiap koreksi diagnosa atau instruksi medis wajib dibuat sebagai baris catatan baru dengan tipe `SOAP_ADDENDUM` yang merujuk pada catatan sebelumnya.
3. Kunjungan medis (`encounters`) memiliki siklus hidup status yang tegas: `ARRIVED -> IN_PROGRESS -> COMPLETED`. Setelah berstatus `COMPLETED`, tidak ada catatan baru yang dapat ditautkan ke kunjungan tersebut tanpa persetujuan komite medik.

## Konsekuensi
- **Konsekuensi Positif:** Jaminan kepatuhan hukum 100%, rekam medis kebal terhadap malpraktik pemalsuan catatan masa lalu.
- **Konsekuensi Negatif:** Antarmuka dokter membutuhkan fitur komparasi adendum agar riwayat perkembangan klinis pasien mudah dibaca secara kronologis.
