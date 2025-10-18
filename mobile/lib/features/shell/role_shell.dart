import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../core/dio_client.dart';
import '../attendance/presentation/qr_scan_checkin_screen.dart';
import '../qr/presentation/qr_generator_screen.dart';
import '../profile/presentation/profile_admin_screen.dart';
import '../attendance/presentation/admin_day_report_detail_screen.dart';

class RoleShell extends StatefulWidget {
  final Map<String, dynamic> user;
  const RoleShell({super.key, required this.user});

  @override
  State<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<RoleShell> {
  int _index = 0;

  bool get isAdmin {
    final raw = widget.user['roles'];
    final List roles = raw is List ? raw : const [];
    final names = roles.map((e) {
      if (e is Map && e['name'] != null) return e['name'].toString();
      return e.toString();
    }).map((s) => s.toLowerCase()).toList();
    return names.contains('admin');
  }

  Future<void> _logout() async {
    await DioClient().clearToken();
    if (mounted) Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomeTab(isAdmin: isAdmin),
      if (isAdmin) const QrGeneratorScreen() else const QrScanCheckInScreen(),
  const ProfileAdminScreen(),
    ];
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      if (isAdmin)
        const BottomNavigationBarItem(icon: Icon(Icons.qr_code_2), label: 'Generate QR')
      else
        const BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan QR'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Absenku - ${isAdmin ? 'Admin' : 'Karyawan'}'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout), tooltip: 'Logout'),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: items,
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  final bool isAdmin;
  const _HomeTab({this.isAdmin = false});
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final Dio _dio = DioClient().dio;
  bool _loading = false;
  String? _error;
  int _hadir = 0;
  int _telat = 0;
  int _absen = 0;
  final List<Map<String, dynamic>> _lateItems = [];
  final List<Map<String, dynamic>> _pendingItems = [];
  final List<Map<String, dynamic>> _absentItems = [];

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) {
      _loadToday();
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
      final res = await _dio.get('/attendance/report/rollcall', queryParameters: {'date': dateStr});
      int hadir = 0, telat = 0, absen = 0;
      _lateItems.clear();
      _pendingItems.clear();
      _absentItems.clear();
      final list = (res.data as List).cast<dynamic>();
      for (final e in list) {
        final m = Map<String, dynamic>.from(e as Map);
        final status = (m['status'] ?? '') as String;
        if (status == 'HADIR') {
          hadir++;
        } else if (status == 'TELAT') {
          telat++;
          _lateItems.add(m);
        } else if (status == 'ABSEN') {
          absen++;
          _absentItems.add(m);
        } else {
          // '-': belum diputuskan sebelum cutoff 16:30 WIB
          _pendingItems.add(m);
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
        if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
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
                  if (icon != null) Icon(icon, size: 16, color: color.withValues(alpha: 0.9)),
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
    // Employee home (non-admin): tetap sederhana
    if (!widget.isAdmin) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/my-attendance'),
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Riwayat Absensi Saya'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Admin dashboard content
    // Tentukan daftar yang akan ditampilkan sebagai missing/pending
    final displayedMissing = _absen > 0 ? _absentItems : _pendingItems;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('Hari ini', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Muat ulang',
                    onPressed: _loading ? null : _loadToday,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              Row(
                children: [
                  _kpiCard(title: 'Hadir', count: _hadir, color: Colors.green.shade700, icon: Icons.check_circle),
                  const SizedBox(width: 8),
                  _kpiCard(title: 'Telat', count: _telat, color: Colors.orange.shade800, icon: Icons.schedule),
                  const SizedBox(width: 8),
                  _kpiCard(title: 'Absen', count: _absen, color: Colors.red.shade700, icon: Icons.cancel),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.calendar_month, size: 18),
                    label: const Text('Laporan Harian'),
                    onPressed: () => Navigator.pushNamed(context, '/admin-report-day'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.fact_check, size: 18),
                    label: const Text('Rollcall Hari Ini'),
                    onPressed: () {
                      final w = DateTime.now().toUtc().add(const Duration(hours: 7));
                      final d = DateTime(w.year, w.month, w.day);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AdminDayReportDetailScreen(date: d)),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Ringkasan cepat di bawah chips (minimalis)
              if (_telat > 0) _sectionTitle('Telat ($_telat)'),
              if (_telat > 0)
                _miniList(
                  items: _lateItems,
                  icon: Icons.schedule,
                  iconColor: Colors.orange.shade800,
                  showTime: true,
                ),
              if (displayedMissing.isNotEmpty) _sectionTitle(_absen > 0 ? 'Absen ($_absen)' : 'Belum Check-in'),
              if (displayedMissing.isNotEmpty)
                _miniList(
                  items: displayedMissing,
                  icon: _absen > 0 ? Icons.cancel : Icons.remove_circle_outline,
                  iconColor: _absen > 0 ? Colors.red.shade700 : Colors.grey.shade700,
                ),
              if (_loading) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  Widget _miniList({
    required List<Map<String, dynamic>> items,
    required IconData icon,
    required Color iconColor,
    bool showTime = false,
  }) {
    final max = items.length > 5 ? 5 : items.length;
    return Card(
      elevation: 0,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: max,
        itemBuilder: (ctx, i) {
          final it = items[i];
          final name = (it['name'] ?? it['email'] ?? '-') as String;
          String? timeStr;
          if (showTime) {
            final raw = it['check_in_at'];
            DateTime? dt;
            if (raw is String) {
              dt = DateTime.tryParse(raw);
            } else if (raw is DateTime) {
              dt = raw;
            }
            if (dt != null) {
              timeStr = DateFormat('HH:mm').format(dt.toLocal());
            }
          }
          return ListTile(
            dense: true,
            leading: Icon(icon, color: iconColor),
            title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: showTime && timeStr != null ? Text(timeStr) : null,
            onTap: () {
              // Tap item -> buka rollcall hari ini
              final w = DateTime.now().toUtc().add(const Duration(hours: 7));
              final d = DateTime(w.year, w.month, w.day);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AdminDayReportDetailScreen(date: d)),
              );
            },
          );
        },
        separatorBuilder: (ctx, i) => const Divider(height: 1),
      ),
    );
  }
}

// Profile tab now uses ProfileAdminScreen (dummy UI)
