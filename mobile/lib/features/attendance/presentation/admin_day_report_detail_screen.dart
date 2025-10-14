import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../core/dio_client.dart';

class AdminDayReportDetailScreen extends StatefulWidget {
  final DateTime date;
  const AdminDayReportDetailScreen({super.key, required this.date});

  @override
  State<AdminDayReportDetailScreen> createState() => _AdminDayReportDetailScreenState();
}

class _AdminDayReportDetailScreenState extends State<AdminDayReportDetailScreen> {
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _rows = [];
  final Dio _dio = DioClient().dio;

  String get _dateStr => DateFormat('yyyy-MM-dd').format(widget.date);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _dio.get('/attendance/report/rollcall', queryParameters: {'date': _dateStr});
      final data = (res.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
      setState(() {
        _rows = data;
      });
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      if (status == 401) {
        setState(() => _error = 'Sesi berakhir. Silakan login kembali.');
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            }
          });
        }
      } else {
        setState(() => _error = 'Gagal memuat laporan: ${e.message}');
      }
    } catch (e) {
      setState(() => _error = 'Gagal memuat laporan: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    final isFuture = widget.date.isAfter(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail ${DateFormat('d MMMM yyyy', 'id_ID').format(widget.date)}'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _rows.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline, color: Colors.black54),
                            const SizedBox(height: 8),
                            Text(
                              isFuture
                                  ? 'Tanggal belum berjalan. Data akan muncul setelah ada absensi.'
                                  : 'Tidak ada data untuk tanggal ini. Pastikan pengguna dengan role EMPLOYEE sudah terdaftar.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _loading ? null : _load,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Muat ulang'),
                            )
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemBuilder: (context, i) {
                    final it = _rows[i];
                    final name = (it['name'] ?? it['email'] ?? '-').toString();
                    final email = (it['email'] ?? '').toString();
                    final status = (it['status'] ?? '-').toString(); // ABSEN/HADIR/TELAT/-
                    DateTime? inAt = it['check_in_at'] != null ? DateTime.tryParse(it['check_in_at']) : null;
                    DateTime? outAt = it['check_out_at'] != null ? DateTime.tryParse(it['check_out_at']) : null;
                    final statusColor = status == 'TELAT'
                        ? Colors.orange
                        : (status == 'ABSEN' ? Colors.red : (status == '-' ? Colors.grey : Colors.green));
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEAEAEA)),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(top: 6, right: 12),
                            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                if (email.isNotEmpty)
                                  Text(email, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                const SizedBox(height: 8),
                                if (isFuture)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text('Tanggal belum berjalan', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: [
                                    _kv('Status', status),
                                    _kv('IN', inAt != null ? timeFmt.format(inAt.toLocal()) : '-'),
                                    _kv('OUT', outAt != null ? timeFmt.format(outAt.toLocal()) : '-'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: _rows.length,
                ),
    );
  }
}

Widget _kv(String label, String value) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('$label: ', style: const TextStyle(color: Colors.black54)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  );
}
