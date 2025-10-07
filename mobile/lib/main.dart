import 'package:flutter/material.dart';

void main() {
  runApp(const AbsenkuApp());
}

class AbsenkuApp extends StatelessWidget {
  const AbsenkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absenku',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const Scaffold(
        body: Center(child: Text('Absenku Mobile - fresh start')),
      ),
    );
  }
}