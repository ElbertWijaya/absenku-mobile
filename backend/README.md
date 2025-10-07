# Absenku Backend (NestJS + TypeORM + MariaDB)

Path proyek lokal:
E:\Kuliah\STMIK TIME\Semester 7\Pemograman Mobile Lanjutan\Absenku\backend

Prerequisites
- Node.js 20+ dan npm 10+ (cek versi: `node -v`, `npm -v`)
- MariaDB 10.5+ berjalan lokal (atau remote)
- Buat database dan user:
  ```sql
  CREATE DATABASE absensi_db CHARACTER SET utf8mb4;
  CREATE USER 'absensi_user'@'%' IDENTIFIED BY 'supersecret';
  GRANT ALL PRIVILEGES ON absensi_db.* TO 'absensi_user'@'%';
  FLUSH PRIVILEGES;
  ```

Setup
1) Salin `.env.example` menjadi `.env`, isi kredensial DB & konfigurasi lain.
2) Install dependencies:
   npm install
3) Jalankan migrasi DB:
   npm run migration:run
4) Start dev:
   npm run start:dev
5) Swagger:
   http://localhost:3000/docs
6) Health check:
   http://localhost:3000/health

Migrations
- File migrasi berada di `src/database/migrations/`
  - `20251007090000_init_schema.ts` (skema awal)
  - `20251007090500_multilocation_shift_defaults.ts` (multi-lokasi + default shift)
- Perintah:
  - Jalankan: `npm run migration:run`
  - Revert 1 langkah: `npm run migration:revert`
  - Buat migration kosong: `npm run migration:create -- --name add_table_x`
  - Generate dari entity (opsional): `npm run migration:generate` (butuh entity lengkap)

Catatan
- `synchronize=false` (aman untuk produksi). Semua perubahan skema lewat migrations.
- Timezone koneksi DB diset ke UTC (`timezone: 'Z'`), konversi tampilan di aplikasi.