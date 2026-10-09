# ADR-005: Mesin Status Berhingga Penugasan Pengemudi dan Pencatatan Log Audit

## Status
Diterima (*Accepted*)

## Konteks
Sistem pencocokan penugasan pengemudi (*driver matchmaking*) memiliki kondisi persaingan ketat (*high-concurrency race condition*). Beberapa pengemudi dapat menerima pesanan yang sama secara bersamaan, atau penumpang membatalkan pesanan tepat pada saat pengemudi telah menerima penugasan. Tanpa pemodelan status berhingga yang terisolasi, pengemudi bisa ditugaskan ke perjalanan yang sudah dibatalkan atau satu pengemudi menerima dua pesanan aktif.

## Keputusan
Kami memutuskan untuk:
1. Memodelkan status perjalanan sebagai Mesin Status Berhingga (Finite State Machine):
   `REQUESTED -> SEARCHING_DRIVER -> ACCEPTED -> PICKING_UP -> ON_TRIP -> COMPLETED`
   dengan jalur pembatalan bersyarat (`CANCELLED`).
2. Penetapan pengemudi wajib menggunakan kueri atomik dengan penguncian optimistik (*optimistic locking*) atau pemeriksaan status prasyarat:
   ```sql
   UPDATE trips
   SET driver_id = $driver_id, trip_status = 'ACCEPTED'
   WHERE id = $trip_id AND trip_status = 'SEARCHING_DRIVER';
   ```
3. Setiap perubahan status wajib merekam satu baris riwayat di `trip_status_logs` mencakup pemicu sumber aksi (`trigger_source`).

## Konsekuensi
- **Konsekuensi Positif:** Mencegah penugasan ganda (*double-booking*), jejak kronologis perselisihan ongkos atau pembatalan dapat diverifikasi secara objektif.
- **Konsekuensi Negatif:** Perekaman log status menambah beban I/O penulisan yang memerlukan pemeliharaan partisi tabel berkala (*table partitioning*).
