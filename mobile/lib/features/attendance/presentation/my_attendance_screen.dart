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

  // removed _fmtDateTimeLocal (unused)

  String _fmtDateLocal(String? ymd) {
    if (ymd == null || ymd.isEmpty) return '-';
    try {
      // Parse "YYYY-MM-DD" sebagai lokal (tanpa zona waktu)
      final parts = ymd.split('-');
      if (parts.length != 3) return ymd;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final dt = DateTime(year, month, day);
      return DateFormat('dd MMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return ymd;
    }
  }

  String _fmtTimeLocal(dynamic value) {
    if (value == null) return '';
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
      return DateFormat('HH:mm:ss', 'id_ID').format(local);
    } catch (_) {
      // Fallback: ambil bagian waktu dari string ISO
      var s = value.toString().replaceFirst('T', ' ').replaceFirst('Z', '');
      final dot = s.indexOf('.');
      if (dot != -1) s = s.substring(0, dot);
      final parts = s.split(' ');
      if (parts.length >= 2) return parts[1];
      return s;
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
      appBar: AppBar(title: const Text('Riwayat Absensi Saya (Lokal)')),
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
                    final inTime = _fmtTimeLocal(inAt);
                    final outTime = _fmtTimeLocal(outAt);
                    final outLine = (outAt == null || outTime.isEmpty)
                        ? 'OUT: '
                        : 'OUT: $outTime WIB';
                    return ListTile(
                      title: Text('Tanggal: ${_fmtDateLocal(date)} | Shift: ${it['shift_id']} | Lokasi: ${it['location_id']}'),
                      subtitle: Text('IN: $inTime WIB\n$outLine'),
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
