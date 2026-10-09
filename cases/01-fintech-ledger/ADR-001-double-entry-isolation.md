# ADR-001: Isolasi Mutasi Finansial Berbasis Pembukuan Ganda Tak Terubah

## Status
Diterima (*Accepted*)

## Konteks
Sistem finansial dan gerbang pembayaran sering menghadapi risiko korupsi data akibat mutasi saldo langsung (*direct balance update*) pada satu baris tabel akun. Pendekatan mutasi langsung rentan terhadap kondisi balapan (*race condition*), hilangnya jejak audit masa lalu, dan selisih saldo yang mustahil ditelusuri akar masalahnya.

## Keputusan
Kami memutuskan untuk:
1. Menerapkan pola pembukuan ganda (*double-entry bookkeeping*) formal: setiap transaksi wajib memiliki minimal dua baris jurnal (`journal_lines`) di mana total nominal DEBIT wajib sama persis dengan total nominal KREDIT.
2. Saldo akun tidak disimpan sebagai angka tetap yang dapat diubah bebas, melainkan dihitung dari agregasi matematis seluruh baris jurnal yang telah berstatus `is_posted = true`.
3. Seluruh baris transaksi berstatus tak terubah (*immutable*): koreksi transaksi wajib dilakukan melalui jurnal pembalik (*reversing entry*), bukan dengan menghapus baris lama.

## Konsekuensi
- **Konsekuensi Positif:** Jejak audit 100% transparan, kepatuhan audit perbankan/keuangan terjamin, dan tidak ada saldo yang hilang tanpa sumber transaksi.
- **Konsekuensi Negatif:** Perhitungan saldo berjalan (*running balance*) membutuhkan strategi caching atau *materialized view* untuk akun dengan jutaan mutasi per detik.
