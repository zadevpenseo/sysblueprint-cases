# Architecture Decision Record: Enterprise Data Lineage & Observability

## Status
Diterima (*Accepted*) - 2026-10-09

## Konteks dan Latar Belakang Masalah
Dalam ekosistem data modern dengan ratusan tabel fakta dan dimensi yang saling terhubung, perubahan skema tanpa koordinasi di sistem hulu sering kali memicu kerusakan fatal pada dasbor eksekutif dan laporan keuangan di sistem hilir (*silent data corruption*). Tim rekayasa data membutuhkan sistem pelacakan silsilah data (*data lineage*) dan deteksi pergeseran skema (*schema drift*) yang mampu menghitung dampak radius ledakan (*blast radius score*) secara dini sebelum laporan analitik dikonsumsi oleh para pemangku kepentingan.

Tantangan utama adalah bagaimana memodelkan hubungan silsilah data antar-tabel serta mencatat anomali secara terstruktur di dalam basis data relasional tanpa membebani latensi operasional sistem transaksi harian.

## Evaluasi Pilihan Alternatif dan Trade-Off

### Opsi 1: Penguraian Log Kueri Retrospektif (Query Log Parsing)
Mengurai riwayat kueri SQL dari log basis data secara periodik untuk memetakan dependensi tabel.
* Kelebihan: Tidak memerlukan modifikasi pada kode aplikasi hulu.
* Kekurangan: Deteksi bersifat pasif dan lambat. Sering gagal mengenali dependensi dinamis atau transformasi kompleks di luar basis data utama.

### Opsi 2: Pelacakan Berbasis Metrik dan Agen Pihak Ketiga (SaaS Monolith)
Memasang agen observabilitas berbayar yang memonitor seluruh koneksi jaringan dan basis data.
* Kelebihan: Antarmuka visual bawaan dan integrasi otomatis dengan pustaka populer.
* Kekurangan: Biaya langganan lisensi sangat tinggi, risiko kebocoran data privasi pelanggan ke pihak ketiga, serta penguncian vendor (*vendor lock-in*).

### Opsi 3: Pola Buku Besar Silsilah Data Terintegrasi (Lineage Audit Ledger + Open Metadata Export)
Menerapkan skema relasional terdedikasi (`lineage_audit_log` dan `schema_drift_alerts`) yang diperbarui pada saat eksekusi pipa transformasi data (dbt/ETL), dengan kemampuan ekspor manifes standar kompatibel Monte Carlo dan OpenLineage.
* Kelebihan: Sepenuhnya milik organisasi (*zero vendor lock-in*), tanpa biaya lisensi bulanan, menjamin integritas relasional via kunci asing, dan dapat diekspor langsung ke berbagai platform orkestrasi data modern.
* Kekurangan: Pengembang pipa transformasi wajib menyertakan langkah pencatatan status pada akhir alur kerja *batch*.

## Keputusan Arsitektur
Organisasi menetapkan **Opsi 3: Pola Buku Besar Silsilah Data Terintegrasi** sebagai standar arsitektur observabilitas data.

Alasan penetapan:
1. Memungkinkan penghitungan skor *blast radius* secara deterministik langsung di tingkat basis data.
2. Memfasilitasi integrasi dua arah: data dapat dianalisis secara lokal menggunakan kueri SQL standar dan dapat diekspor ke format JSON kompatibel ekosistem observabilitas data global seperti Monte Carlo dan OpenLineage.
3. Menjaga kepatuhan tata kelola data internal tanpa ketergantungan infrastruktur pihak ketiga.

## Konsekuensi dan Strategi Mitigasi
* **Peningkatan Volume Log Mutasi**: Tabel `lineage_audit_log` akan bertambah seiring frekuensi eksekusi job. Mitigasi: Terapkan strategi partisi waktu bulanan (*monthly range partitioning*) dan arsipkan data yang berusia lebih dari 90 hari ke penyimpanan dingin.
* **Disiplin Pengembang**: Memerlukan konvensi penamaan seragam untuk aset data hulu dan hilir. Mitigasi: Otomasi validasi penamaan melalui pemeriksaan pra-komit pada modul dbt dan pustaka orkestrasi.
