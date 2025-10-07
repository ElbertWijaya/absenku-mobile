# Admin Web (Next.js + React)

Tujuan
- Panel admin terpisah untuk manajemen QR, karyawan, shift, jadwal, laporan, dan payroll.

Stack yang disarankan
- Next.js 14+ (App Router), TypeScript
- UI: shadcn/ui + Tailwind CSS
- Data: TanStack Query (React Query)
- Tabel: TanStack Table
- Chart: Tremor (opsional)
- Auth: JWT Bearer (akses API), simpan di `HttpOnly` cookie + CSRF (opsional)

Halaman utama
- Login
- Dashboard: metrik harian (hadir, telat, belum checkout), grafis sederhana
- QR Display: pilih lokasi + shift → tampilkan QR (auto refresh berdasarkan `QR_TOKEN_ROTATION_SECONDS`)
- Employees: list, create/edit, set defaults (lokasi & shift)
- Shifts: CRUD
- Schedules: calendar (hari/minggu/bulan), generate otomatis
- Attendance: filter by tanggal/lokasi/karyawan, ekspor CSV
- Payroll: generate periode, lihat rincian per karyawan, ekspor

Env contoh
- NEXT_PUBLIC_API_BASE_URL=http://localhost:3000

Implementasi QR Display (ringkas)
- Interval fetch `/qr/active?location_id=&shift_id=` setiap N detik (atau Server-Sent Events/WebSocket bila ingin realtime).
- Render QR menggunakan `qrcode.react`.
- Fallback bila gagal fetch: retry dengan backoff dan indikator koneksi.

Keamanan
- Gunakan role ADMIN untuk akses panel.
- Rate limiting di backend tetap aktif (whitelist IP kantor bila perlu).