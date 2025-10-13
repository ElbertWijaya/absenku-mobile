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
  static const List<String> _monthNames = <String>[
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];


  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Bulan & Tahun', style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Tahun
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selected.year,
                        items: _yearOptions
                            .map((y) => DropdownMenuItem(value: y, child: Text('Tahun $y')))
                            .toList(),
                        onChanged: (v) => v == null ? null : _onChangeYM(year: v),
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
                        value: _selected.month,
                        items: List<DropdownMenuItem<int>>.generate(
                          12,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text(_monthNames[i]),
                          ),
                        ),
                        onChanged: (v) => v == null ? null : _onChangeYM(month: v),
                        decoration: const InputDecoration(
                          labelText: 'Bulan',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          '${_monthNames[_selected.month - 1]} ${_selected.year}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        final now = DateTime.now();
                        _onChangeYM(year: now.year, month: now.month);
                      },
                      icon: const Icon(Icons.today),
                      label: const Text('Hari ini'),
                    ),
                  ],
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
                            child: Text(_summaryError!, style: const TextStyle(color: Colors.red)),
                          ),
                        _MonthGrid(
                          year: _selected.year,
                          month: _selected.month,
                          daysWithData: _daysWithData,
                          daysWithLate: _daysWithLate,
                          daysAllOnTime: _daysAllOnTime,
                          onDayTap: (d) => _openDayDetail(DateTime(_selected.year, _selected.month, d)),
                        ),
                        const SizedBox(height: 8),
                        _LegendRow(),
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
      for (final it in list) {
        final wd = (it['work_date'] ?? '') as String;
        if (wd.length >= 10) {
          final day = int.tryParse(wd.substring(8, 10));
          if (day != null) {
            days.add(day);
            final lateCount = (it['late_count'] ?? 0) as int;
            final onTimeCount = (it['on_time_count'] ?? 0) as int;
            if (lateCount > 0) daysLate.add(day);
            if (lateCount == 0 && onTimeCount > 0) daysOnTime.add(day);
          }
        }
      }
      setState(() {
        _daysWithData = days;
        _daysWithLate = daysLate;
        _daysAllOnTime = daysOnTime;
      });
    } catch (e) {
      setState(() => _summaryError = 'Gagal memuat ringkasan bulan: $e');
    } finally {
      setState(() => _loadingSummary = false);
    }
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
  final ValueChanged<int> onDayTap;
  const _MonthGrid({required this.year, required this.month, required this.daysWithData, required this.daysWithLate, required this.daysAllOnTime, required this.onDayTap});

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
            final isToday = (year == now.year && month == now.month && dayNum == now.day);
            final hasData = daysWithData.contains(dayNum);
            final hasLate = daysWithLate.contains(dayNum);
            final allOnTime = daysAllOnTime.contains(dayNum);
            final cs = Theme.of(context).colorScheme;
            final bg = isToday ? cs.primary : null;
            final borderColor = isToday ? cs.primary : const Color(0xFF222222);
            final textStyle = TextStyle(
              fontWeight: FontWeight.w600,
              color: isToday ? cs.onPrimary : null,
            );
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => onDayTap(dayNum),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bg,
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
                            color: hasLate ? Colors.orange : (allOnTime ? Colors.green : cs.primary),
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
        ],
      ),
    );
  }
}
