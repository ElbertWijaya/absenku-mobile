import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';

class AdminDayReportScreen extends StatefulWidget {
  const AdminDayReportScreen({super.key});

  @override
  State<AdminDayReportScreen> createState() => _AdminDayReportScreenState();
}

class _AdminDayReportScreenState extends State<AdminDayReportScreen> {
  DateTime _selected = DateTime.now();
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _logs = [];
  final Dio _dio = DioClient().dio;
  late final List<int> _yearOptions;
  static const List<String> _monthNames = <String>[
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_selected);

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  Future<void> _onChangeYMD({int? year, int? month, int? day}) async {
    final y = year ?? _selected.year;
    final m = month ?? _selected.month;
    final maxDay = _daysInMonth(y, m);
    final d = (day ?? _selected.day).clamp(1, maxDay);
    setState(() => _selected = DateTime(y, m, d));
    await _load();
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
    final now = DateTime.now();
    _yearOptions = List<int>.generate(4, (i) => now.year - 2 + i);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Harian Absensi'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter tanggal', style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Tahun
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _selected.year,
                        items: _yearOptions
                            .map((y) => DropdownMenuItem(value: y, child: Text('Tahun $y')))
                            .toList(),
                        onChanged: (v) => v == null ? null : _onChangeYMD(year: v),
                        decoration: const InputDecoration(
                          labelText: 'Tahun',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Bulan
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _selected.month,
                        items: List<DropdownMenuItem<int>>.generate(
                          12,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text(_monthNames[i]),
                          ),
                        ),
                        onChanged: (v) => v == null ? null : _onChangeYMD(month: v),
                        decoration: const InputDecoration(
                          labelText: 'Bulan',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tanggal
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _selected.day.clamp(1, _daysInMonth(_selected.year, _selected.month)),
                        items: List<int>.generate(
                                _daysInMonth(_selected.year, _selected.month), (i) => i + 1)
                            .map((d) => DropdownMenuItem(value: d, child: Text('Hari $d')))
                            .toList(),
                        onChanged: (v) => v == null ? null : _onChangeYMD(day: v),
                        decoration: const InputDecoration(
                          labelText: 'Tanggal',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_dateStr, style: Theme.of(context).textTheme.titleMedium),
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
