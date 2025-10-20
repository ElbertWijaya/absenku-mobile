import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multicast_dns/multicast_dns.dart';
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
  ));

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

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

    // Try mDNS discovery only when baseUrl looks like local
    try {
      if (dio.options.baseUrl.contains('localhost') || dio.options.baseUrl.contains('10.0.2.2')) {
        final discovered = await _discoverBackendOnLan(timeoutSeconds: 2);
        if (discovered != null) {
          dio.options.baseUrl = discovered;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('mDNS discovery failed: $e');
    }

    if (kDebugMode) {
      debugPrint('DEBUG API_BASE_URL (effective): ${dio.options.baseUrl}');
    }

    _initialized = true;
  }

  Future<String?> _discoverBackendOnLan({int timeoutSeconds = 2}) async {
    final mdns = MDnsClient();
    await mdns.start();
    try {
      final ptr = mdns.lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer('_absenku._tcp.local'));
      await for (final ptrRecord in ptr.timeout(Duration(seconds: timeoutSeconds))) {
        final srvRecords = mdns.lookup<SrvResourceRecord>(ResourceRecordQuery.service(ptrRecord.domainName));
        await for (final srv in srvRecords.timeout(Duration(seconds: timeoutSeconds))) {
          final ipRecords = mdns.lookup<IPAddressResourceRecord>(ResourceRecordQuery.addressIPv4(srv.target));
          await for (final ip in ipRecords.timeout(Duration(seconds: timeoutSeconds))) {
            return 'http://${ip.address.address}:${srv.port}';
          }
        }
      }
    } catch (_) {
      // ignore
    } finally {
      mdns.stop();
    }
    return null;
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
  }
}
/*
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';
import 'package:multicast_dns/multicast_dns.dart';

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
    // Inject Authorization header from secure storage
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));

    // Auto-discovery via mDNS if apiBaseUrl not overridden and looks like localhost/emulator
    try {
      final isOverridden = const bool.hasEnvironment('API_BASE_URL');
      if (!isOverridden && (dio.options.baseUrl.contains('localhost') || dio.options.baseUrl.contains('10.0.2.2'))) {
        final discovered = await _discoverBackendOnLan(timeoutSeconds: 2);
        if (discovered != null) {
          dio.options.baseUrl = discovered;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('mDNS discovery failed: $e');
    }

    // Info untuk memastikan base URL benar (hanya saat debug)
    if (kDebugMode) {
      debugPrint('DEBUG API_BASE_URL (effective): ${dio.options.baseUrl}');
    }
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);

    _initialized = true;
  }

  Future<String?> _discoverBackendOnLan({int timeoutSeconds = 2}) async {
    final mdns = MDnsClient();
    await mdns.start();
    try {
      final ptr = mdns.lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer('_absenku._tcp.local'));
      await for (final ptrRecord in ptr.timeout(Duration(seconds: timeoutSeconds))) {
        final srvRecords = mdns.lookup<SrvResourceRecord>(ResourceRecordQuery.service(ptrRecord.domainName));
        await for (final srv in srvRecords.timeout(Duration(seconds: timeoutSeconds))) {
          final ipRecords = mdns.lookup<IPAddressResourceRecord>(ResourceRecordQuery.addressIPv4(srv.target));
          await for (final ip in ipRecords.timeout(Duration(seconds: timeoutSeconds))) {
            return 'http://${ip.address.address}:${srv.port}';
          }
        }
      }
    } catch (_) {
      // ignore discovery errors
    } finally {
      mdns.stop();
    }
    return null;
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
*/