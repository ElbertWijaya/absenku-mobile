import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme_controller.dart';
import '../data/profile_repository.dart';
import '../../auth/data/auth_repository.dart';

class ProfileEmployeeScreen extends StatefulWidget {
  const ProfileEmployeeScreen({super.key});

  @override
  State<ProfileEmployeeScreen> createState() => _ProfileEmployeeScreenState();
}

class _ProfileEmployeeScreenState extends State<ProfileEmployeeScreen> {
  final _authRepo = AuthRepository();
  // Mock data (dummy)
  String email = '...';
  String username = '';
  String fullName = '';
  String phone = '';
  final List<String> roles = const ['EMPLOYEE'];

  // Local UI state
  bool editingPhone = false;
  final usernameC = TextEditingController();
  final fullNameC = TextEditingController();
  final phoneC = TextEditingController();

  String themePref = 'system'; // system | light | dark
  final repo = ProfileRepository();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMe();
    final mode = ThemeController.instance.mode;
    setState(() {
      themePref = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
    });
  }

  @override
  void dispose() {
    usernameC.dispose();
    fullNameC.dispose();
    phoneC.dispose();
    super.dispose();
  }

  Future<void> _loadMe() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await repo.me();
      final user = data;
      final emp = (user['employee'] ?? {}) as Map<String, dynamic>;
      setState(() {
        email = (user['email'] ?? '').toString();
        username = (user['username'] ?? '').toString();
        fullName = (emp['full_name'] ?? '').toString();
        phone = (emp['phone'] ?? '').toString();
        usernameC.text = username;
        fullNameC.text = fullName;
        phoneC.text = phone;
      });
    } catch (e) {
      setState(() => _error = 'Gagal memuat profil: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      );

  Widget _readonlyField(String label, String value, {bool canCopy = false}) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
      subtitle: Text(value.isEmpty ? '-' : value),
      trailing: canCopy
          ? IconButton(
              tooltip: 'Salin',
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email disalin')),
                );
              },
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Karyawan'),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionTitle('Akun'),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              _readonlyField('Email', email, canCopy: true),
              _sectionTitle('Data Personal'),
              _readonlyField('Nama Lengkap', fullName),
              _readonlyField('Username', username),
              _readonlyField('Nomor HP', phone),
              _sectionTitle('Preferensi'),
              const ListTile(
                dense: true,
                visualDensity: VisualDensity(horizontal: 0, vertical: -2),
                title: Text('Tema', style: TextStyle(color: Colors.black54)),
                subtitle: Text('Sistem'),
              ),
              const ListTile(
                dense: true,
                visualDensity: VisualDensity(horizontal: 0, vertical: -2),
                title: Text('Bahasa', style: TextStyle(color: Colors.black54)),
                subtitle: Text('id-ID'),
              ),
              _sectionTitle('Keamanan'),
              ListTile(
                dense: true,
                visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                leading: const Icon(Icons.lock),
                title: const Text('Ubah Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Implement change password dialog if needed
                },
              ),
              _sectionTitle('Tentang'),
              const ListTile(
                dense: true,
                visualDensity: VisualDensity(horizontal: 0, vertical: -2),
                title: Text('Versi aplikasi', style: TextStyle(color: Colors.black54)),
                subtitle: Text('v1.0.0+1'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  onPressed: () async {
                    await _authRepo.logout();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Berhasil logout/token dihapus.')),
                      );
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_loading) const Padding(
                padding: EdgeInsets.only(top: 12),
                child: LinearProgressIndicator(minHeight: 2),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
