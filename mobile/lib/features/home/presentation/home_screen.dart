import 'package:flutter/material.dart';
import '../../../core/dio_client.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await DioClient().clearToken();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absenku - Home'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const Center(
        child: Text('Login berhasil. Menu Scan & Riwayat akan ditambahkan.'),
      ),
    );
  }
}