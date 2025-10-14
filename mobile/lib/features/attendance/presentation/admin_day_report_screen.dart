import 'package:flutter/material.dart';
import 'admin_day_report_detail_screen.dart';
import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';

class AdminDayReportScreen extends StatefulWidget {
  const AdminDayReportScreen({super.key});

  @override
  State<AdminDayReportScreen> createState() => _AdminDayReportScreenState();
}

class _AdminDayReportScreenState extends State<AdminDayReportScreen> {
  DateTime _selected = DateTime.now();
  late final List<int> _yearOptions;
  final Dio _dio = DioClient().dio;
  bool _loadingSummary = false;
  String? _summaryError;
  Set<int> _daysWithData = <int>{};
  Set<int> _daysWithLate = <int>{};
  Set<int> _daysAllOnTime = <int>{};
  Set<int> _daysAllAbsent = <int>{};
  // DEBUG: store raw per-day summary for inspection
  Map<int, Map<String, dynamic>> _daySummary = <int, Map<String, dynamic>>{};
  static const List<String> _monthNames = <String>[
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];


  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  Future<void> _pickYear() async {
    final chosen = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text('Pilih Tahun', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              ..._yearOptions.map((y) => ListTile(
                    title: Text('$y'),
                    trailing: y == _selected.year ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.pop(ctx, y),
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (chosen != null) {
      await _onChangeYM(year: chosen);
    }
  }

  Future<void> _pickMonth() async {
    final chosen = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text('Pilih Bulan', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              ...List.generate(12, (i) => i + 1).map((m) => ListTile(
                    title: Text(_monthNames[m - 1]),
                    trailing: m == _selected.month ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.pop(ctx, m),
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (chosen != null) {
      await _onChangeYM(month: chosen);
    }
  }

  Future<void> _onChangeYM({int? year, int? month}) async {
    final y = year ?? _selected.year;
    final m = month ?? _selected.month;
    final maxDay = _daysInMonth(y, m);
    final d = _selected.day.clamp(1, maxDay);
    setState(() => _selected = DateTime(y, m, d));
    await _loadMonthSummary();
  }

  void _openDayDetail(DateTime date) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminDayReportDetailScreen(date: date),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _yearOptions = List<int>.generate(4, (i) => now.year - 2 + i);
    // initial load of month summary
    _loadMonthSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Harian Absensi'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _loadingSummary ? null : _loadMonthSummary,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          '${_monthNames[_selected.month - 1]} ${_selected.year}',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onPressed: () {
                        final now = DateTime.now();
                        _onChangeYM(year: now.year, month: now.month);
                      },
                      icon: const Icon(Icons.today),
                      label: const Text('Hari ini'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Very compact chips for explicit Year/Month pickers
                Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      ActionChip(
                        label: Text('${_selected.year}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        avatar: const Icon(Icons.calendar_today, size: 16),
                        onPressed: _pickYear,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      ActionChip(
                        label: Text(_monthNames[_selected.month - 1], style: const TextStyle(fontWeight: FontWeight.w600)),
                        avatar: const Icon(Icons.expand_more, size: 16),
                        onPressed: _pickMonth,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Weekday header (Senin..Minggu)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _Wd('Senin'), _Wd('Selasa'), _Wd('Rabu'), _Wd('Kamis'), _Wd('Jumat'), _Wd('Sabtu'), _Wd('Minggu'),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFEAEAEA)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Column(
                      children: [
                        if (_summaryError != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(_summaryError!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: _loadingSummary ? null : _loadMonthSummary,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Coba lagi'),
                                ),
                              ],
                            ),
                          ),
                        _MonthGrid(
                          year: _selected.year,
                          month: _selected.month,
                          daysWithData: _daysWithData,
                          daysWithLate: _daysWithLate,
                          daysAllOnTime: _daysAllOnTime,
                          daysAllAbsent: _daysAllAbsent,
                          onDayTap: (d) => _openDayDetail(DateTime(_selected.year, _selected.month, d)),
                          onDayLongPress: (d) => _showDayDebug(d),
                        ),
                        if (_summaryError == null && !_loadingSummary && _daysWithData.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Belum ada data pada bulan ini.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        const SizedBox(height: 8),
                        _LegendRow(),
                        const SizedBox(height: 6),
                        const _DateLegendRow(),
                        if (_loadingSummary)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: LinearProgressIndicator(minHeight: 2),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Grid-only view; no per-day list here. Detail ada di layar berikutnya.
        ],
      ),
    );
  }

  Future<void> _loadMonthSummary() async {
    setState(() {
      _loadingSummary = true;
      _summaryError = null;
  _daysWithData = <int>{};
  _daysWithLate = <int>{};
  _daysAllOnTime = <int>{};
  _daysAllAbsent = <int>{};
  _daySummary = <int, Map<String, dynamic>>{};
    });
    try {
      final res = await _dio.get('/attendance/report/month-summary', queryParameters: {
        'year': _selected.year,
        'month': _selected.month,
      });
      final list = (res.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
      final days = <int>{};
      final daysLate = <int>{};
      final daysOnTime = <int>{};
      final daysAllAbsent = <int>{};
      for (final it in list) {
        final wd = (it['work_date'] ?? '') as String;
        if (wd.length >= 10) {
          final day = int.tryParse(wd.substring(8, 10));
          if (day != null) {
            _daySummary[day] = it; // keep raw for debug
            final dynamic pRaw = it['present_count'];
            final dynamic eRaw = it['employee_total'];
            int present = pRaw is num ? pRaw.toInt() : int.tryParse('${pRaw ?? 0}') ?? 0;
            final empTotal = eRaw is num ? eRaw.toInt() : int.tryParse('${eRaw ?? 0}') ?? 0;
            final isFuture = it['is_future'] == true;
            final anyLate = (it['any_late'] == true) || (((it['late_count'] ?? 0) as num?)?.toInt() ?? 0) > 0;
            final allOnTimeStrict = (it['all_on_time_strict'] == true);
            // Defensive: if present_count==0 but other counters suggest presence, treat as presence for coloring
            final withOut = ((it['with_out'] ?? 0) as num?)?.toInt() ?? 0;
            final openCount = ((it['open_count'] ?? 0) as num?)?.toInt() ?? 0;
            final onTimeCount = ((it['on_time_count'] ?? 0) as num?)?.toInt() ?? 0;
            final hasPresenceSignals = (withOut + openCount + onTimeCount) > 0;
            if (present == 0 && hasPresenceSignals) present = 1;
            // Derive all-absent strictly from present count to avoid backend/client mismatch
            // Do NOT mark future days (no presence yet) as 'Semua absen'.
            final allAbsent = !isFuture && present == 0 && empTotal > 0;

            // Mark which days show a dot
            // - Future days with 0 presence: no dot.
            if (present > 0 || allAbsent) days.add(day);

            if (allAbsent) daysAllAbsent.add(day);
            // Late takes precedence over on-time
            if (!allAbsent && present > 0 && anyLate) daysLate.add(day);
            // Truly all on-time only when everyone (empTotal) is present and on-time
            if (!allAbsent && present > 0 && !anyLate && allOnTimeStrict && present == empTotal) daysOnTime.add(day);
          }
        }
      }
      setState(() {
        _daysWithData = days;
        _daysWithLate = daysLate;
        _daysAllOnTime = daysOnTime;
        _daysAllAbsent = daysAllAbsent;
      });
    } on DioException catch (e) {
      // Tangani 401: arahkan ke login
      final status = e.response?.statusCode ?? 0;
      if (status == 401) {
        setState(() => _summaryError = 'Sesi berakhir. Silakan login kembali.');
        if (mounted) {
          // Navigasi ke login setelah sedikit delay agar UI sempat update
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            }
          });
        }
      } else {
        setState(() => _summaryError = 'Gagal memuat ringkasan bulan: ${e.message}');
      }
    } catch (e) {
      setState(() => _summaryError = 'Gagal memuat ringkasan bulan: $e');
    } finally {
      setState(() => _loadingSummary = false);
    }
  }

  // DEBUG helper: show raw summary in a modal for the selected day
  void _showDayDebug(int day) {
    final data = _daySummary[day];
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        if (data == null) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Tidak ada data ringkasan untuk hari ini.'),
          );
        }
        // Show only the requested fields
        final workDate = (data['work_date'] ?? '-') as String;
        final present = ((data['present_count'] ?? 0) as num?)?.toInt() ?? 0;
        final late = ((data['late_count'] ?? 0) as num?)?.toInt() ?? 0;
        final totalEmp = ((data['employee_total'] ?? 0) as num?)?.toInt() ?? 0;
        final absent = (totalEmp - present) < 0 ? 0 : (totalEmp - present);
        List<Widget> rows = <MapEntry<String, String>>[
          const MapEntry('Tanggal', ''),
          const MapEntry('Jumlah Hadir', ''),
          const MapEntry('Jumlah Telat', ''),
          const MapEntry('Jumlah Absen', ''),
          const MapEntry('Total Karyawan', ''),
        ]
            .asMap()
            .entries
            .map((e) {
          final label = e.value.key;
          final value = () {
            switch (label) {
              case 'Tanggal':
                return workDate;
              case 'Jumlah Hadir':
                return '$present';
              case 'Jumlah Telat':
                return '$late';
              case 'Jumlah Absen':
                return '$absent';
              case 'Total Karyawan':
                return '$totalEmp';
              default:
                return '';
            }
          }();
          return MapEntry(label, value);
        })
            .map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 160, child: Text(entry.key, style: const TextStyle(color: Colors.black54))),
                      const SizedBox(width: 8),
                      Expanded(child: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w600))),
                    ],
                  ),
                ))
            .toList();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Debug ringkasan: ${_selected.year}-${_selected.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const SizedBox(height: 12),
                  ...rows,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Wd extends StatelessWidget {
  final String text;
  const _Wd(this.text);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 20,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final int year;
  final int month;
  final Set<int> daysWithData;
  final Set<int> daysWithLate;
  final Set<int> daysAllOnTime;
  final Set<int> daysAllAbsent;
  final ValueChanged<int> onDayTap;
  final ValueChanged<int>? onDayLongPress;
  const _MonthGrid({required this.year, required this.month, required this.daysWithData, required this.daysWithLate, required this.daysAllOnTime, required this.daysAllAbsent, required this.onDayTap, this.onDayLongPress});

  int _daysInMonth(int y, int m) => DateTime(y, m + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(year, month, 1);
    final startWeekday = first.weekday; // 1=Mon..7=Sun
    final totalDays = _daysInMonth(year, month);

    // number of leading empty cells before day 1
    final leading = startWeekday - 1; // 0..6
    final totalCells = leading + totalDays;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (r) {
        return Row(
          children: List.generate(7, (c) {
            final idx = r * 7 + c; // 0-based
            final dayNum = idx - leading + 1; // 1-based day
            if (dayNum < 1 || dayNum > totalDays) {
              return const Expanded(child: SizedBox(height: 42));
            }
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final cellDate = DateTime(year, month, dayNum);
            final isToday = cellDate.year == today.year && cellDate.month == today.month && cellDate.day == today.day;
            final isPast = cellDate.isBefore(today);
            final isFuture = cellDate.isAfter(today);
            final hasData = daysWithData.contains(dayNum);
            final hasLate = daysWithLate.contains(dayNum);
            final allOnTime = daysAllOnTime.contains(dayNum);
            final allAbsent = daysAllAbsent.contains(dayNum);
      final cs = Theme.of(context).colorScheme;
      // Background tints for clearer visual separation
      final Color bg = isToday
        ? cs.primary
        : (isPast
          ? const Color(0xFFEDEDED) // slightly darker gray for past
          : const Color(0xFFF4F6FF)); // subtle blue-ish tint for future
      final borderColor = isToday
        ? cs.primary
        : (isPast ? const Color(0xFFB0B0B0) : const Color(0xFFB5C2FF));
      final textStyle = TextStyle(
              fontWeight: FontWeight.w600,
              color: isToday ? cs.onPrimary : (isFuture ? Colors.black54 : Colors.black87),
            );
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onDayTap(dayNum),
                onLongPress: onDayLongPress == null ? null : () => onDayLongPress!(dayNum),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text('$dayNum', style: textStyle),
                      ),
                      const SizedBox(height: 4),
                      if (hasData)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: allAbsent
                                ? Colors.red
                                : (hasLate ? Colors.orange : (allOnTime ? Colors.green : cs.primary)),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

class _LegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget item(Color color, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          item(Colors.green, 'Semua tepat waktu'),
          item(Colors.orange, 'Ada terlambat'),
          item(cs.primary, 'Campuran'),
          item(Colors.red, 'Semua absen'),
        ],
      ),
    );
  }
}

class _DateLegendRow extends StatelessWidget {
  const _DateLegendRow();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget box({Color? bg, required Color border, required String text}) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: border, width: 2),
            ),
          ),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          box(bg: const Color(0xFFEDEDED), border: const Color(0xFFB0B0B0), text: 'Tanggal lewat'),
          box(bg: cs.primary, border: cs.primary, text: 'Hari ini'),
          box(bg: const Color(0xFFF4F6FF), border: const Color(0xFFB5C2FF), text: 'Mendatang'),
        ],
      ),
    );
  }
}
