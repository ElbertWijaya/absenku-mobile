import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';

class DioClient {
  static final DioClient _i = DioClient._internal();
  factory DioClient() => _i;
  DioClient._internal();

  final Dio dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Content-Type': 'application/json'},
    // Optional: anggap 4xx/5xx sebagai error (default sudah begitu)
  ));

  final _storage = const FlutterSecureStorage();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Log request/response hanya saat debug
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        requestHeader: false,
        logPrint: (obj) => debugPrint('[DIO] $obj'),
      ));
    }

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));

    // Info untuk memastikan base URL benar (hanya saat debug)
    if (kDebugMode) {
      debugPrint('DEBUG API_BASE_URL: $apiBaseUrl');
    }

    _initialized = true;
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
  }
}