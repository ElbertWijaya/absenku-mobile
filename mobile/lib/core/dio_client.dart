import 'package:dio/dio.dart';
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

  Future<void> init() async {
    // Log request/response untuk debug 401
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      requestHeader: false,
      logPrint: (obj) => print('[DIO] $obj'),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));

    // Info untuk memastikan base URL benar
    // ignore: avoid_print
    print('DEBUG API_BASE_URL: $apiBaseUrl');
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
  }
}