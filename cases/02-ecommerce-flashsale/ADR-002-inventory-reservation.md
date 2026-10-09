# ADR-002: Pemisahan Mutasi Stok Fisik dan Reservasi Sementara Flash-Sale

## Status
Diterima (*Accepted*)

## Konteks
Pada saat acara promosi penjualan kilat (*flash-sale*), ribuan pengguna menekan tombol bayar dalam fraksi detik yang sama. Jika pemotongan stok dilakukan langsung pada tabel `products` menggunakan penguncian baris (`SELECT FOR UPDATE`), basis data akan mengalami kemacetan transaksi (*thread contention*) dan *timeout*. Selain itu, jika pelanggan membatalkan pembayaran di gerbang pembayaran, memulihkan stok langsung berisiko menyebabkan inkonsistensi.

## Keputusan
Kami memutuskan untuk:
1. Memperkenalkan tabel perantara `stock_reservations` dengan status berbatas waktu (`expires_at`, lazimnya 15 menit).
2. Stok efektif yang tersedia untuk pembeli lain dihitung dari: `available_stock = stock_quantity - SUM(active_reserved_quantity)`.
3. Stok fisik di tabel `products` hanya dipotong secara permanen ketika pesanan berubah menjadi `PAID` (status reservasi menjadi `COMMITTED`).
4. Jika transaksi pembayaran kedaluwarsa, proses latar belakang (*worker*) menandai status menjadi `EXPIRED` sehingga kuota otomatis kembali tersedia tanpa perlu memodifikasi baris produk fisik.

## Konsekuensi
- **Konsekuensi Positif:** Mencegah *overselling*, performa tinggi saat lonjakan transaksi, pembatalan pembayaran tidak mengunci tabel inventaris.
- **Konsekuensi Negatif:** Perlu scheduler berkala untuk membersihkan status reservasi yang kedaluwarsa.
