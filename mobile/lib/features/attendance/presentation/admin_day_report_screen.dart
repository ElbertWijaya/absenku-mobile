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
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _dio.get('/attendance/report/day', queryParameters: { 'date': _dateStr });
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
    final timeFmt = DateFormat('HH:mm:ss');
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
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tanggal: $_dateStr'),
                FilledButton.icon(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh), label: const Text('Muat')),
              ],
            ),
          ),
          if (_error != null) Padding(padding: const EdgeInsets.all(8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: _logs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final it = _logs[i];
                      DateTime? inAt = it['check_in_at'] != null ? DateTime.tryParse(it['check_in_at']) : null;
                      DateTime? outAt = it['check_out_at'] != null ? DateTime.tryParse(it['check_out_at']) : null;
                      final email = it['user_email'] ?? it['user_id']?.toString() ?? '-';
                      final status = it['status'] ?? '-';
                      return ListTile(
                        leading: CircleAvatar(child: Text('${i + 1}')),
                        title: Text(email),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('IN: ${inAt != null ? timeFmt.format(inAt.toLocal()) : '-'} | OUT: ${outAt != null ? timeFmt.format(outAt.toLocal()) : '-'}'),
                          Text('Status: $status | Menit Telat: ${it['late_minutes'] ?? 0} | Kerja: ${it['work_minutes'] ?? 0} mnt'),
                        ]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickDate,
        label: const Text('Pilih Tanggal'),
        icon: const Icon(Icons.date_range),
      ),
    );
  }
}
