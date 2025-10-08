import 'package:flutter/material.dart';
<<<<<<< HEAD

void main() {
=======
import 'core/dio_client.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DioClient().init();
>>>>>>> feat/mobile-login
  runApp(const AbsenkuApp());
}

class AbsenkuApp extends StatelessWidget {
  const AbsenkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absenku',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
<<<<<<< HEAD
      home: const Scaffold(
        body: Center(child: Text('Absenku Mobile - fresh start')),
      ),
=======
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
      },
>>>>>>> feat/mobile-login
    );
  }
}