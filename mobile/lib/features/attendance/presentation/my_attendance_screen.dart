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

  String _fmtDateTimeLocal(dynamic value) {
    if (value == null) return '-';
    try {
      DateTime dt;
      if (value is DateTime) {
        dt = value;
      } else if (value is String) {
        dt = DateTime.parse(value);
      } else {
        return value.toString();
      }
      final local = dt.toLocal();
  return DateFormat('yyyy-MM-dd HH:mm:ss', 'id_ID').format(local);
    } catch (_) {
      final s = value.toString();
      var cleaned = s.replaceFirst('T', ' ').replaceFirst('Z', '');
      // Remove fractional seconds like .000
      final dot = cleaned.indexOf('.');
      if (dot != -1) {
        // keep only up to seconds
        cleaned = cleaned.substring(0, dot);
      }
      return cleaned;
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
                    final inAt = it['check_in_at'];
                    final outAt = it['check_out_at'];
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
