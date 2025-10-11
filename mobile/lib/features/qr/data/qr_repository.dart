import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';

class QrRepository {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getActive() async {
    final res = await _dio.get('/qr/active');
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> issue() async {
    final res = await _dio.post('/qr/issue');
    return Map<String, dynamic>.from(res.data);
  }
}
