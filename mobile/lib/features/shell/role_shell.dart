import 'package:flutter/material.dart';
import '../../core/dio_client.dart';
import '../qr/presentation/qr_generator_screen.dart';
import '../attendance/presentation/qr_scan_checkin_screen.dart';

class RoleShell extends StatefulWidget {
  final Map<String, dynamic> user;
  const RoleShell({super.key, required this.user});

  @override
  State<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<RoleShell> {
  int _index = 0;

  bool get isAdmin {
    final roles = (widget.user['roles'] as List?)?.map((e) => (e is Map) ? e['name'] : e).toList() ?? const [];
    return roles.contains('admin') || roles.contains('Admin');
  }

  Future<void> _logout() async {
    await DioClient().clearToken();
    if (mounted) Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _HomeTab(),
      if (isAdmin) const QrGeneratorScreen() else const QrScanCheckInScreen(),
      const _ProfileTab(),
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

class _HomeTab extends StatelessWidget {
  const _HomeTab();
  @override
  Widget build(BuildContext context) {
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
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile (coming soon)'));
  }
}
