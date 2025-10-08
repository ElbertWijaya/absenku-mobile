import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';

class QrRepository {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getActive({required int locationId, required int shiftId}) async {
    final res = await _dio.get('/qr/active', queryParameters: {
      'location_id': locationId,
      'shift_id': shiftId,
    });
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> issue({required int locationId, required int shiftId}) async {
    final res = await _dio.post('/qr/issue', data: {
      'location_id': locationId,
      'shift_id': shiftId,
    });
    return Map<String, dynamic>.from(res.data);
  }
}
