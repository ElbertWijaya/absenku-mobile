# mobile

A Flutter client for Absenku.

## Quick start

- Make sure the backend is running (see `backend/README.md`).
- Configure the API base URL (see below).
- Run the app on your desired platform.

## API base URL

The app reads the API base URL from a compile-time define:

- Key: `API_BASE_URL`
- Default: `http://10.0.2.2:3000` (Android emulator only)

Override per platform at run time:

- Android emulator: usually no override needed (uses 10.0.2.2 → host machine)
- Physical device: set to your PC IP, for example `http://192.168.1.10:3000`
- Web/Chrome: set to `http://localhost:3000` (ensure backend CORS allows it)

Example run (Chrome):

```
flutter run -d chrome --dart-define API_BASE_URL=http://localhost:3000
```

## Testing guide

For end-to-end testing scenarios (login, QR check-in, reports), follow `mobile/TESTING.md`.

