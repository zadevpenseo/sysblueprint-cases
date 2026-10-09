# SysBlueprint Canonical Architecture Cases

Koleksi resmi studi kasus perancangan sistem dan arsitektur basis data terverifikasi dari [SysBlueprint Studio](https://sysblueprint.blogspot.com/). Repositori ini berfungsi sebagai template acuan bagi praktisi, mahasiswa, dan peneliti dalam merekayasa skema relasional, kamus data, diagram status alur kerja, dan dokumen keputusan arsitektur (*Architecture Decision Records / ADR*).

---

## Daftar Studi Kasus Kanonikal

| ID | Nama Kasus | Domain | Fokus Masalah Rekayasa | Berkas Kasus |
|:---|:---|:---|:---|:---:|
| `CASE-01` | **Double-Entry Financial Ledger** | Fintech / Perbankan | Pembukuan berpasangan terisolasi, jaminan audit transaksi, dan pencegahan saldo negatif asimetris. | [Buka Kasus](cases/01-fintech-ledger/) |
| `CASE-02` | **E-Commerce Flash-Sale Inventory** | E-Commerce / Retail | Penanganan lonjakan reservasi stok terikat batas waktu, isolasi transaksi serializable, dan idempotensi pesanan. | [Buka Kasus](cases/02-ecommerce-flashsale/) |
| `CASE-03` | **Multi-Tenant B2B SaaS Core** | Cloud Software | Isolasi data multitenan berbasis organisasi, kontrol hak akses berbasis peran (RBAC), dan keanggotaan pengguna. | [Buka Kasus](cases/03-multitenant-saas/) |
| `CASE-04` | **Hospital Patient EMR** | Layanan Kesehatan | Rekam medis pasien terintegrasi, jejak riwayat klinis yang tidak dapat diubah (*immutable clinical logs*), dan audit kepatuhan. | [Buka Kasus](cases/04-hospital-emr/) |
| `CASE-05` | **On-Demand Ride-Hailing Matchmaking** | Transportasi / Logistik | Mesin status alokasi penugasan pengemudi, pelacakan koordinat perjalanan, dan perhitungan tarif dinamis. | [Buka Kasus](cases/05-ridehailing-matchmaking/) |

---

## Anatomi Berkas Setiap Studi Kasus

Setiap folder kasus disusun secara modular dan terstandar:

```
cases/<nomor-kasus>/
├── schema.sql              # Kode DDL ANSI SQL-92 / PostgreSQL terurut topologis
├── ERD.md                  # Diagram Entitas Relasi format Mermaid
├── DATA_DICTIONARY.md      # Kamus data lengkap: tipe data, kendala (constraints), deskripsi bisnis
└── ADR-*.md                # Dokumen Keputusan Arsitektur formal (Konteks, Keputusan, Konsekuensi)
```

---

## Cara Menggunakan sebagai Template Proyek

1. Klik tombol **Use this template** di pojok kanan atas repositori ini untuk membuat repositori portofolio pribadi Anda di GitHub.
2. Buka dan eksplorasi skema kasus di [SysBlueprint Studio](https://sysblueprint.blogspot.com/p/database-designer.html).
3. Modifikasi berkas DDL, lengkapi kamus data, dan kirimkan tautan repositori Anda ke [SysBlueprint Community](https://github.com/zadevpenseo/sysblueprint-community) untuk dinilai oleh sistem evaluasi otomatis.

---

## Lisensi

Seluruh materi arsitektur dan kode DDL dalam repositori ini dilisensikan di bawah lisensi terbuka [MIT](LICENSE).
