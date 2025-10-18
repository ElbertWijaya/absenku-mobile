# Absenku Mobile - Testing Guide

This document walks you through end-to-end testing of the Flutter app against the local backend.

Prerequisites
- Backend running locally on http://localhost:3000 (see `backend/README.md`)
- Seeded users for login
- Flutter SDK installed (3.19+ recommended), Android/iOS tooling as needed

1) Backend setup (once)
- Install dependencies and run DB migrations (see `backend/README.md`).
- Start backend in watch mode so changes auto-reload:
  - `npm run start:dev` (from the `backend` folder)
- Seed accounts (one-time):
  - Admin: `npm run seed:admin` → admin@example.com / Admin@123
  - Employees: `npm run seed:users` → users with password Password@123
- Ensure CORS allows your target (default allows http://localhost:5173; you can add http://localhost:8080 or others via `CORS_ORIGINS` in `.env`).

2) Configure API base URL (mobile)
The app reads `API_BASE_URL` at compile-time (see `lib/core/config.dart`). Pick the right value:
- Android emulator: default `http://10.0.2.2:3000` (no override required)
- Web/Chrome: `http://localhost:3000`
- Physical device: `http://<your-computer-LAN-IP>:3000` (ensure phone and PC are on the same Wi‑Fi)

Examples:
- Chrome: `flutter run -d chrome --dart-define API_BASE_URL=http://localhost:3000`
- Android device: `flutter run -d <deviceId> --dart-define API_BASE_URL=http://192.168.1.10:3000`

3) Run the app
- From the `mobile` folder run: `flutter pub get`
- Run on your target device with the appropriate `--dart-define` (see above)
- First screen is Login

4) Login
- Admin login: admin@example.com / Admin@123 (role ADMIN)
- Employee login: one of the seeded emails (e.g., elbert@example.com) with Password@123 (role EMPLOYEE)

5) Key flows to test
A. Employee QR check-in
- Login as EMPLOYEE
- Go to "Scan QR (Check-in)" and scan a QR generated from the backend (or use the QR generator in the app for demo).
- Expected:
  - Upon success: a toast/snackbar or success state; the attendance log appears under "Riwayat Saya".
  - If after the on-time cutoff (default 09:15 WIB), the log status shows TELAT with `late_minutes`.

B. Employee My Attendance (Riwayat)
- Navigate to "Riwayat Saya".
- Expected:
  - Logs listed with date (local), check-in/out times, and status (HADIR/TELAT/—/ABSEN) according to rules.

C. Admin - Laporan Harian (Monthly Summary)
- Login as ADMIN
- Open "Laporan Harian Absensi".
- Use the chips to pick Year/Month and the "Hari ini" button to jump back.
- Expected per calendar day:
  - Past days: dot shows when there is presence; late indicator when TELAT exists.
  - Future days: no dots for 0 presence.
  - Today: "Semua absen" only after 16:30 WIB.
- Long-press a day to see a concise debug with exactly five fields: Tanggal, Jumlah Hadir, Jumlah Telat, Jumlah Absen, Total Karyawan.

D. Admin - Detail Hari (Rollcall)
- Tap a day to open detail.
- Pull to refresh via AppBar button.
- Expected:
  - Before 16:30 WIB today: users without scans show "-".
  - After 16:30 WIB: users without scans show "ABSEN".
  - Late users marked TELAT; on-time users HADIR.
  - 401 responses redirect to login.

6) Time rules and environment
- On-time cutoff: 09:15 WIB (configurable via backend env `ATTENDANCE_ON_TIME_CUTOFF`, format HH:mm)
- Absent cutoff: 16:30 WIB (configurable via backend env `ATTENDANCE_ABSENT_CUTOFF`)
- All time-based checks use WIB (UTC+7) consistently on the server.

7) Troubleshooting
- 401 Unauthorized:
  - Token expired/cleared. Log in again.
  - Ensure backend is running and API base URL points to the correct host.
- Cannot connect from device:
  - Use your LAN IP instead of localhost and allow firewall.
- Dots/summary mismatch:
  - Verify server month summary vs. rollcall; ensure you’re on the latest backend with date normalization fix.
- Scanner issues (Android):
  - Some devices require camera permission prompts. If crashes persist, update `mobile_scanner` and clean build artifacts.

8) Optional checks
- Run analyzer: `flutter analyze`
- Run widget tests: `flutter test`

That’s it—this guide should get you through typical QA scenarios quickly. If you need additional cases (multi-location/shift), we can expand this doc.
