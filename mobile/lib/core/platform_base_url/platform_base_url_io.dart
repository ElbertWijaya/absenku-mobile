import 'dart:io' show Platform;

// Platform-aware defaults for non-web targets using dart:io
// - Android emulator: 10.0.2.2
// - iOS simulator: 127.0.0.1
// - Windows/macOS/Linux desktop: localhost
String get defaultPlatformBaseUrl {
  if (Platform.isAndroid) return 'http://10.0.2.2:3000';
  if (Platform.isIOS) return 'http://127.0.0.1:3000';
  // Windows/macOS/Linux
  return 'http://localhost:3000';
}
