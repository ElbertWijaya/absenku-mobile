import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';

class AuthRepository {
  final Dio _dio;
  final DioClient _client;
  AuthRepository({Dio? dio, DioClient? client})
      : _client = client ?? DioClient(),
        _dio = (client ?? DioClient()).dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = res.data as Map<String, dynamic>;
    final token = data['access_token'] as String?;
    if (token != null) {
      await _client.saveToken(token);
    }
    return data;
  }
}