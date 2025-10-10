import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../attendance/data/attendance_repository.dart';

class MyAttendanceScreen extends StatefulWidget {
  const MyAttendanceScreen({super.key});

  @override
  State<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends State<MyAttendanceScreen> {
  final repo = AttendanceRepository();
  List<Map<String, dynamic>> _logs = [];
  bool _loading = false;
  String? _error;

  String _fmtDateTimeLocal(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd MMM yyyy HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await repo.myLogs();
      setState(() => _logs = data);
    } catch (e) {
      setState(() => _error = 'Gagal memuat riwayat: $e');
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
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absensi Saya')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.separated(
                  itemCount: _logs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final it = _logs[i];
                    final date = it['work_date'] as String?;
                    final inAt = it['check_in_at'] as String?;
                    final outAt = it['check_out_at'] as String?;
                    return ListTile(
                      title: Text('Tanggal: ${date ?? '-'} | Shift: ${it['shift_id']} | Lokasi: ${it['location_id']}'),
                      subtitle: Text('IN: ${_fmtDateTimeLocal(inAt)} WIB\nOUT: ${_fmtDateTimeLocal(outAt)} WIB'),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _load,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
