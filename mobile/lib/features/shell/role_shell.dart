import 'dart:async';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../core/dio_client.dart';
import '../qr/presentation/qr_generator_screen.dart';
import '../profile/presentation/profile_admin_screen.dart';
import '../profile/presentation/profile_employee_screen.dart';
import '../attendance/presentation/admin_day_report_detail_screen.dart';
import '../attendance/data/attendance_repository.dart';

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

  @override
  Widget build(BuildContext context) {
    Widget buildBody() {
      switch (_index) {
        case 0:
          return _HomeTab(isAdmin: isAdmin);
        case 1:
          // Non-admin: tab Scan diubah menjadi aksi push route, jadi body tidak perlu diisi scan.
          // Admin: tetap gunakan Generator.
          if (isAdmin) return const QrGeneratorScreen();
          return _HomeTab(isAdmin: false);
        default:
          if (isAdmin) {
            return const ProfileAdminScreen();
          } else {
            return const ProfileEmployeeScreen();
          }
      }
    }
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      if (isAdmin)
        const BottomNavigationBarItem(icon: Icon(Icons.qr_code_2), label: 'Generate QR')
      else
        const BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan QR'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];
    return Scaffold(
      body: buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          if (!isAdmin && i == 1) {
            // Untuk karyawan, tombol Scan bertindak sebagai aksi membuka route scan.
            Navigator.pushNamed(context, '/scan-checkin');
            return;
          }
          setState(() => _index = i);
        },
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
  final AttendanceRepository _attRepo = AttendanceRepository();
  bool _loading = false;
  String? _error;
  int _hadir = 0;
  int _telat = 0;
  int _absen = 0;
  final List<Map<String, dynamic>> _lateItems = [];
  final List<Map<String, dynamic>> _pendingItems = [];
  final List<Map<String, dynamic>> _absentItems = [];

  // Employee state
  bool _myLoading = false;
  String? _myError;
  Map<String, dynamic>? _myToday;
  List<Map<String, dynamic>> _recentLogs = [];
  int _monthPresent = 0;
  int _monthLate = 0;
  int _monthAbsent = 0;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) {
      _loadToday();
    } else {
      _refreshEmployee();
    }
  }

  // Fetch and update admin dashboard data
  Future<void> _loadToday() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final now = DateTime.now().toUtc().add(const Duration(hours: 7));
      String pad2(int n) => n.toString().padLeft(2, '0');
      final today = '${now.year}-${pad2(now.month)}-${pad2(now.day)}';
      final summary = await _attRepo.adminTodaySummary(date: today);
      setState(() {
        _hadir = summary['hadir'] ?? 0;
        _telat = summary['telat'] ?? 0;
        _absen = summary['absen'] ?? 0;
        _lateItems
          ..clear()
          ..addAll(List<Map<String, dynamic>>.from(summary['lateItems'] ?? []));
        _pendingItems
          ..clear()
          ..addAll(List<Map<String, dynamic>>.from(summary['pendingItems'] ?? []));
        _absentItems
          ..clear()
          ..addAll(List<Map<String, dynamic>>.from(summary['absentItems'] ?? []));
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _refreshEmployee() async {
    setState(() {
      _myLoading = true;
      _myError = null;
    });
    try {
      final now = DateTime.now().toUtc().add(const Duration(hours: 7));
      String pad2(int n) => n.toString().padLeft(2, '0');
      final today = '${now.year}-${pad2(now.month)}-${pad2(now.day)}';
      final response = await _dio.get('/attendance/my-today');
      final data = response.data as Map<String, dynamic>;
      setState(() {
        _myToday = data['today'];
        _recentLogs = List<Map<String, dynamic>>.from(data['recent'] ?? []);
        _monthPresent = data['monthPresent'] ?? 0;
        _monthLate = data['monthLate'] ?? 0;
        _monthAbsent = data['monthAbsent'] ?? 0;
        _myLoading = false;
      });
    } catch (e) {
      setState(() {
        _myError = e.toString();
        _myLoading = false;
      });
    }
  }

  Future<void> _doCheckOut() async {
    try {
      await _dio.post('/attendance/check-out');
      await _refreshEmployee();
    } catch (e) {
      setState(() {
        _myError = e.toString();
      });
    }
  }

  String _greetingWIB() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final hour = now.hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _dateTimeWIBLabel() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    return DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id_ID').format(now);
  }

  int _workdaysSoFarInMonth() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    int count = 0;
    for (int i = 1; i <= now.day; i++) {
      final d = DateTime(now.year, now.month, i);
      if (d.weekday != DateTime.saturday && d.weekday != DateTime.sunday) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAdmin) {
      // Admin dashboard content
      final List<Map<String, dynamic>> displayedMissing = _absen > 0 ? _absentItems : _pendingItems;
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: RefreshIndicator(
              onRefresh: _loadToday,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                    if (_telat > 0) _sectionTitle('Telat ($_telat)'),
                    if (_telat > 0)
                      _miniList(
                        items: _lateItems,
                        icon: Icons.schedule,
                        iconColor: Colors.orange.shade800,
                        showTime: true,
                        context: context,
                      ),
                    if (displayedMissing.isNotEmpty) _sectionTitle(_absen > 0 ? 'Absen ($_absen)' : 'Belum Check-in'),
                    if (displayedMissing.isNotEmpty)
                      _miniList(
                        items: displayedMissing,
                        icon: _absen > 0 ? Icons.cancel : Icons.remove_circle_outline,
                        iconColor: _absen > 0 ? Colors.red.shade700 : Colors.grey.shade700,
                        context: context,
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
        ),
      );
    } else {
      // Employee home
      final log = _myToday;
      final hasCheckIn = log != null;
      final isOpen = hasCheckIn && (log['check_out_at'] == null);
      DateTime? inAt;
      DateTime? outAt;
      if (hasCheckIn) {
        final ci = log['check_in_at'];
        final co = log['check_out_at'];
        inAt = ci is String ? DateTime.tryParse(ci)?.toLocal() : (ci is DateTime ? ci.toLocal() : null);
        outAt = co is String ? DateTime.tryParse(co)?.toLocal() : (co is DateTime ? co.toLocal() : null);
      }
      String statusText;
      Color statusColor;
      if (!hasCheckIn) {
        statusText = 'Belum Check-In';
        statusColor = Colors.grey.shade700;
      } else if (isOpen) {
        final lateMin = (log['late_minutes'] ?? 0) as int;
        statusText = lateMin > 0 ? 'Sudah Check-In (TELAT)' : 'Sudah Check-In (HADIR)';
        statusColor = lateMin > 0 ? Colors.orange.shade800 : Colors.green.shade700;
      } else {
        final lateMin = (log['late_minutes'] ?? 0) as int;
        statusText = lateMin > 0 ? 'Selesai (TELAT)' : 'Selesai (HADIR)';
        statusColor = lateMin > 0 ? Colors.orange.shade800 : Colors.green.shade700;
      }
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: RefreshIndicator(
            onRefresh: _refreshEmployee,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(_greetingWIB(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(_dateTimeWIBLabel(), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Status Hari Ini', style: TextStyle(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Muat ulang',
                        onPressed: _myLoading ? null : _refreshEmployee,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  if (_myError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(_myError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(statusText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: statusColor)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.login, size: 16),
                              const SizedBox(width: 6),
                              Text('Check-In: ${inAt != null ? DateFormat('HH:mm').format(inAt) : '-'}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.logout, size: 16),
                              const SizedBox(width: 6),
                              Text('Check-Out: ${outAt != null ? DateFormat('HH:mm').format(outAt) : '-'}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.timelapse, size: 16),
                              const SizedBox(width: 6),
                              Text(_buildDurationLabel(inAt: inAt, outAt: outAt, rawMinutes: (log?['work_minutes'] as int?))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isOpen)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _myLoading ? null : _doCheckOut,
                        icon: const Icon(Icons.logout),
                        label: const Text('Check-Out Sekarang'),
                      ),
                    )
                  else ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Gunakan tombol Scan QR di navigation bar bawah untuk Check-In.',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/my-attendance');
                        if (mounted) await _refreshEmployee();
                      },
                      icon: const Icon(Icons.list_alt),
                      label: const Text('Riwayat Absensi Saya'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = (constraints.maxWidth - 16) / 3; // 16 for spacing
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SizedBox(width: cardWidth, child: _miniStatCard(title: 'Hadir bln ini', value: _monthPresent, color: Colors.indigo, context: context)),
                          SizedBox(width: cardWidth, child: _miniStatCard(title: 'Telat bln ini', value: _monthLate, color: Colors.orange.shade800, context: context)),
                          SizedBox(width: cardWidth, child: _miniStatCard(title: 'Absen bln ini', value: _monthAbsent, color: Colors.red.shade700, context: context)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _progressRing(context),
                  const SizedBox(height: 12),
                  if (_recentLogs.isNotEmpty) ...[
                    const Text('Riwayat Terbaru', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Card(
                      elevation: 0,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recentLogs.length,
                        itemBuilder: (ctx, i) {
                          final it = _recentLogs[i];
                          final ymd = (it['work_date'] ?? '') as String?;
                          String dateLabel = '-';
                          if (ymd != null && ymd.length >= 10) {
                            try {
                              final parts = ymd.substring(0, 10).split('-');
                              final d = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
                              dateLabel = DateFormat('EEE, dd MMM yyyy', 'id_ID').format(d);
                            } catch (_) {}
                          }
                          final ci = it['check_in_at'];
                          final co = it['check_out_at'];
                          final inAt = ci is String ? DateTime.tryParse(ci)?.toLocal() : (ci is DateTime ? ci.toLocal() : null);
                          final outAt = co is String ? DateTime.tryParse(co)?.toLocal() : (co is DateTime ? co.toLocal() : null);
                          final lateMin = (it['late_minutes'] ?? 0) as int;
                          final isLate = lateMin > 0 || (it['status'] == 'late');
                          final statusColor = isLate ? Colors.orange.shade800 : Colors.green.shade700;
                          return ListTile(
                            dense: true,
                            leading: Icon(isLate ? Icons.schedule : Icons.check_circle, color: statusColor),
                            title: Text(dateLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Row(
                              children: [
                                const Icon(Icons.login, size: 14),
                                const SizedBox(width: 4),
                                Text(inAt != null ? DateFormat('HH:mm').format(inAt) : '-'),
                                const SizedBox(width: 12),
                                const Icon(Icons.logout, size: 14),
                                const SizedBox(width: 4),
                                Text(outAt != null ? DateFormat('HH:mm').format(outAt) : '-'),
                              ],
                            ),
                            onTap: () async {
                              await Navigator.pushNamed(context, '/my-attendance');
                              if (mounted) await _refreshEmployee();
                            },
                          );
                        },
                        separatorBuilder: (ctx, i) => const Divider(height: 1),
                      ),
                    ),
                  ] else ...[
                    Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Belum ada riwayat dalam 14 hari terakhir.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ],
                  if (_myLoading) ...[
                    const SizedBox(height: 16),
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
    required BuildContext context,
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

  // Build duration label string
  String _buildDurationLabel({DateTime? inAt, DateTime? outAt, int? rawMinutes}) {
    if (inAt == null) return 'Durasi: -';
    if (outAt == null) {
      final now = DateTime.now();
      final minutes = now.difference(inAt).inMinutes;
      final h = (minutes ~/ 60);
      final m = (minutes % 60);
      return 'Durasi Berjalan: ${h}j ${m}m';
    }
    final minutes = rawMinutes ?? outAt.difference(inAt).inMinutes;
    final h = (minutes ~/ 60);
    final m = (minutes % 60);
    return 'Durasi: ${h}j ${m}m';
  }

  Widget _miniStatCard({required String title, required int value, required Color color, required BuildContext context}) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('$value', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressRing(BuildContext context) {
    final target = _workdaysSoFarInMonth();
    final present = _monthPresent;
    final pct = target == 0 ? 0.0 : (present / target).clamp(0.0, 1.0);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(value: pct, strokeWidth: 6),
                  Text('${(pct * 100).round()}%'),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Progress kehadiran bulan ini', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Hadir $present dari $target hari kerja'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard({required String title, required int count, required Color color, required IconData icon}) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 6),
                  Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Text('$count', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

// Profile tab now uses ProfileAdminScreen (dummy UI)
