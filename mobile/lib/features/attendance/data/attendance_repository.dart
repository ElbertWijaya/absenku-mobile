import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';

class AttendanceRepository {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> checkIn({
    required String qrToken,
    double? lat,
    double? lng,
  }) async {
    final res = await _dio.post('/attendance/check-in', data: {
      'qr_token': qrToken,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    });
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> checkOut({
    double? lat,
    double? lng,
  }) async {
    final res = await _dio.post('/attendance/check-out', data: {
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    });
    return Map<String, dynamic>.from(res.data);
  }

  Future<List<Map<String, dynamic>>> myLogs({String? start, String? end}) async {
    final res = await _dio.get('/attendance/my', queryParameters: {
      if (start != null) 'start': start,
      if (end != null) 'end': end,
    });
    final data = res.data as List;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
