import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';

class AdminDayReportScreen2 extends StatefulWidget {
  const AdminDayReportScreen2({super.key});

  @override
  State<AdminDayReportScreen2> createState() => _AdminDayReportScreen2State();
}

class _AdminDayReportScreen2State extends State<AdminDayReportScreen2> {
  DateTime _selected = DateTime.now();
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _logs = [];
  final Dio _dio = DioClient().dio;

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_selected);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 2);
    final last = DateTime(now.year + 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      setState(() => _selected = picked);
      await _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _dio.get('/attendance/report/day', queryParameters: {'date': _dateStr});
      final data = (res.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
      setState(() => _logs = data);
    } catch (e) {
      setState(() => _error = 'Gagal memuat laporan: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Harian Absensi'),
        actions: [
          IconButton(onPressed: _pickDate, icon: const Icon(Icons.calendar_month)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tanggal dipilih', style: TextStyle(color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text(_dateStr, style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Muat'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Pilih'),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: _logs.length,
                    itemBuilder: (context, i) {
                      final it = _logs[i];
                      DateTime? inAt = it['check_in_at'] != null ? DateTime.tryParse(it['check_in_at']) : null;
                      DateTime? outAt = it['check_out_at'] != null ? DateTime.tryParse(it['check_out_at']) : null;
                      final email = it['user_email'] ?? it['user_id']?.toString() ?? '-';
                      final status = (it['status'] ?? '-').toString();
                      final late = it['late_minutes'] ?? 0;
                      final work = it['work_minutes'] ?? 0;
                      Color statusColor;
                      switch (status) {
                        case 'late':
                          statusColor = Colors.orange;
                          break;
                        case 'on_time':
                          statusColor = Colors.green;
                          break;
                        default:
                          statusColor = Colors.blueGrey;
                      }
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFEAEAEA)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(child: Text('${i + 1}')),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            email,
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          child: Text(
                                            status.toUpperCase(),
                                            style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.login, size: 16, color: Colors.black45),
                                        const SizedBox(width: 6),
                                        Text('IN: ${inAt != null ? timeFmt.format(inAt.toLocal()) : '-'}'),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.logout, size: 16, color: Colors.black45),
                                        const SizedBox(width: 6),
                                        Text('OUT: ${outAt != null ? timeFmt.format(outAt.toLocal()) : '-'}'),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.watch_later, size: 16, color: Colors.black45),
                                        const SizedBox(width: 6),
                                        Text('Telat: $late mnt'),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.timelapse, size: 16, color: Colors.black45),
                                        const SizedBox(width: 6),
                                        Text('Kerja: $work mnt'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
