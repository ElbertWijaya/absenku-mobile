import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository({Dio? dio}) : _dio = (dio ?? DioClient().dio);

  Future<Map<String, dynamic>> me() async {
    final res = await _dio.get('/me');
    return (res.data as Map).cast<String, dynamic>();
  }

  // Update identity: full_name and username
  Future<Map<String, dynamic>> updateIdentity({
    String? fullName,
    String? username,
  }) async {
    final res = await _dio.patch('/me/identity', data: {
      if (fullName != null) 'full_name': fullName,
      if (username != null) 'username': username,
    });
    return (res.data as Map).cast<String, dynamic>();
  }

  // Update phone (employee field)
  Future<Map<String, dynamic>> updatePhone({
    required String phone,
  }) async {
    final res = await _dio.patch('/me/phone', data: {
      'phone': phone,
    });
    return (res.data as Map).cast<String, dynamic>();
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.post('/auth/change-password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }
}
