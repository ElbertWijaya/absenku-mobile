// Platform-aware API base URL with dart-define override
// Precedence:
// 1) --dart-define=API_BASE_URL=...
// 2) Platform-specific default:
//    - Android emulator: http://10.0.2.2:3000
//    - iOS simulator:   http://127.0.0.1:3000
//    - Windows/macOS/Linux desktop: http://localhost:3000
//    - Device (Android/iOS) on LAN: you should still override via dart-define to your PC IP
import 'platform_base_url/platform_base_url_stub.dart'
    if (dart.library.io) 'platform_base_url/platform_base_url_io.dart'
    if (dart.library.html) 'platform_base_url/platform_base_url_web.dart';

const String _overrideApiBaseUrl = String.fromEnvironment('API_BASE_URL');

// This is the resolved base URL used by DioClient
final String apiBaseUrl = (_overrideApiBaseUrl.isNotEmpty)
    ? _overrideApiBaseUrl
    : defaultPlatformBaseUrl;