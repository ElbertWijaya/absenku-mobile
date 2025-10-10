import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/dio_client.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/qr/presentation/qr_generator_screen.dart';
import 'features/attendance/presentation/qr_scan_checkin_screen.dart';
import 'features/attendance/presentation/my_attendance_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  await DioClient().init();
  runApp(const AbsenkuApp());
}

class AbsenkuApp extends StatelessWidget {
  const AbsenkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absenku',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/qr-generate': (_) => const QrGeneratorScreen(),
        '/scan-checkin': (_) => const QrScanCheckInScreen(),
        '/my-attendance': (_) => const MyAttendanceScreen(),
      },
    );
  }
}