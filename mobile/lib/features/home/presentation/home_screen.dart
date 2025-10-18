import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/dio_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Dio _dio = DioClient().dio;
  bool _loading = false;
  String? _error;
  int _hadir = 0;
  int _telat = 0;
  int _absen = 0;

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  Future<void> _logout() async {
    await DioClient().clearToken();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  String _todayWIB() {
    final nowWib = DateTime.now().toUtc().add(const Duration(hours: 7));
    String pad2(int n) => n.toString().padLeft(2, '0');
    return '${nowWib.year}-${pad2(nowWib.month)}-${pad2(nowWib.day)}';
  }

  Future<void> _loadToday() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dateStr = _todayWIB();
      final res = await _dio.get('/attendance/report/rollcall', queryParameters: {
        'date': dateStr,
      });
      int hadir = 0, telat = 0, absen = 0;
      final list = (res.data as List).cast<dynamic>();
      for (final e in list) {
        final m = Map<String, dynamic>.from(e as Map);
        final status = (m['status'] ?? '') as String;
        if (status == 'HADIR') {
          hadir++;
        } else if (status == 'TELAT') {
          telat++;
        } else if (status == 'ABSEN') {
          absen++;
        } else {
          // status '-' (belum scan) tidak dihitung sebagai Absen sebelum cutoff 16:30 WIB
        }
      }
      setState(() {
        _hadir = hadir;
        _telat = telat;
        _absen = absen;
      });
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      if (status == 401) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
        }
      } else {
        setState(() => _error = 'Gagal memuat ringkasan: ${e.message}');
      }
    } catch (e) {
      setState(() => _error = 'Gagal memuat ringkasan: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _kpiCard({required String title, required int count, required Color color, IconData? icon}) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null)
                    Icon(icon, size: 16, color: color.withValues(alpha: 0.9)),
                  if (icon != null) const SizedBox(width: 6),
                  Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Text('$count', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _loading ? null : _loadToday,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                // KPI Row
                Row(
                  children: [
                    _kpiCard(title: 'Hadir', count: _hadir, color: Colors.green.shade700, icon: Icons.check_circle),
                    const SizedBox(width: 8),
                    _kpiCard(title: 'Telat', count: _telat, color: Colors.orange.shade800, icon: Icons.schedule),
                    const SizedBox(width: 8),
                    _kpiCard(title: 'Absen', count: _absen, color: Colors.red.shade700, icon: Icons.cancel),
                  ],
                ),
                const SizedBox(height: 16),
                // Navigation sections
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/admin-report-day'),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Laporan Harian (Admin)'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/my-attendance'),
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Riwayat Absensi Saya'),
                  ),
                ),
                if (_loading) ...[
                  const SizedBox(height: 24),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}