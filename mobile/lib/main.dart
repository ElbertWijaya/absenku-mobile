import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/dio_client.dart';
import 'core/theme_controller.dart';
import 'core/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/qr/presentation/qr_generator_screen.dart';
import 'features/attendance/presentation/qr_scan_checkin_screen.dart';
import 'features/attendance/presentation/my_attendance_screen.dart';
import 'features/attendance/presentation/admin_day_report_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  await DioClient().init();
  final theme = ThemeController.instance;
  await theme.load();
  runApp(AbsenkuApp(theme: theme));
}

class AbsenkuApp extends StatelessWidget {
  final ThemeController theme;
  const AbsenkuApp({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: theme,
  builder: (context, _) => MaterialApp(
      title: 'Absenku',
  theme: buildLightTheme(Colors.indigo),
  darkTheme: buildDarkTheme(Colors.indigo),
      themeMode: theme.mode,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/qr-generate': (_) => const QrGeneratorScreen(),
        '/scan-checkin': (ctx) => QrScanCheckInScreen(
              onSuccessNavigateHome: () {
                // Kembali ke shell/home ketika selesai scan
                Navigator.of(ctx).popUntil((r) => r.isFirst);
              },
            ),
        '/my-attendance': (_) => const MyAttendanceScreen(),
        '/admin-report-day': (_) => const AdminDayReportScreen(),
      },
    ));
  }
}