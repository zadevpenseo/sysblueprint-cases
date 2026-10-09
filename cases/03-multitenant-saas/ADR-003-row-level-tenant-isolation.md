# ADR-003: Pola Multitenan Bersama Berbasis Kunci Penyewa dan Kebijakan Keamanan Tingkat Baris

## Status
Diterima (*Accepted*)

## Konteks
Dalam arsitektur perangkat lunak SaaS B2B, terdapat tiga opsi isolasi data:
1. Basis data terpisah per penyewa (*database-per-tenant*): Biaya infrastruktur membengkak tajam dan migrasi skema sangat rumit.
2. Skema terpisah per penyewa (*schema-per-tenant*): Batas jumlah koneksi basis data cepat habis ketika jumlah organisasi mencapai ribuan.
3. Basis data bersama dengan kunci penyewa (*shared database with tenant_id key*): Hemat biaya komputasi dan mudah dirawat, namun membawa risiko fatal kebocoran data lintas organisasi jika pengembang lupa menambahkan klausa `WHERE tenant_id = ?`.

## Keputusan
Kami memutuskan untuk:
1. Menggunakan model basis data bersama (*shared database*) di mana setiap tabel domain bisnis wajib memiliki kolom `tenant_id NOT NULL`.
2. Pengguna dapat memiliki akun tunggal yang tergabung di banyak organisasi via tabel perantara `tenant_memberships` dengan peran (*roles*) berbeda di tiap organisasi.
3. Di tingkat basis data, isolasi diperkuat melalui kebijakan *Row-Level Security* (RLS) PostgreSQL dengan variabel sesi `SET LOCAL app.current_tenant_id = '...'` di setiap awal transaksi koneksi.

## Konsekuensi
- **Konsekuensi Positif:** Biaya operasional hemat (skalabilitas hingga puluhan ribu penyewa tanpa menambah server DB), migrasi skema tunggal yang seragam.
- **Konsekuensi Negatif:** Seluruh kueri wajib menyertakan konteks penyewa aktif dan membutuhkan pengujian unit ketat untuk mencegah kebocoran data lintas batas tenant.
