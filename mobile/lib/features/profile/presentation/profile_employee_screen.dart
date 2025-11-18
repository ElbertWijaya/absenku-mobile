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
    // initialize themePref from controller
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

  Widget _editableField({
    required String label,
    required TextEditingController controller,
    required bool editing,
    required VoidCallback onEdit,
    required VoidCallback onSave,
    required VoidCallback onCancel,
    TextInputType? keyboardType,
  }) {
    final cs = Theme.of(context).colorScheme;
    if (!editing) {
      return ListTile(
        dense: true,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
        subtitle: Text((controller.text).isEmpty ? '-' : controller.text),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit,
          tooltip: 'Edit',
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              FilledButton(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  minimumSize: const Size(0, 36),
                ),
                onPressed: onSave,
                child: const Text('Simpan'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  minimumSize: const Size(0, 36),
                ),
                onPressed: onCancel,
                child: const Text('Batal'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<void> openEditIdentitySheet() async {
      final nameTmp = TextEditingController(text: fullName);
      final userTmp = TextEditingController(text: username);
      await showModalBottomSheet(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16, right: 16,
              top: 8,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Edit Identitas', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameTmp,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: userTmp,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixText: '@',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(visualDensity: VisualDensity.compact, minimumSize: const Size(0, 36)),
                      onPressed: () async {
                        final newFull = nameTmp.text.trim();
                        final newUser = userTmp.text.trim().replaceAll('@', '');
                        // Capture local refs to avoid context across async gaps issues
                        final navigator = Navigator.of(ctx);
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          setState(() => _loading = true);
                          await repo.updateIdentity(fullName: newFull, username: newUser);
                          setState(() {
                            fullName = newFull;
                            username = newUser;
                            fullNameC.text = fullName;
                            usernameC.text = username;
                          });
                          if (!mounted) return;
                          navigator.pop();
                        } catch (e) {
                          // Try to map common backend error messages to friendlier UI text
                          final msg = e.toString();
                          String ui = 'Gagal menyimpan identitas: $e';
                          if (msg.contains('Username sudah dipakai')) {
                            ui = 'Username sudah dipakai. Silakan pilih yang lain.';
                          }
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(content: Text(ui)),
                          );
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                      child: const Text('Simpan'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact, minimumSize: const Size(0, 36)),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(
                    (fullName.isNotEmpty ? fullName : username)
                        .trim()
                        .split(' ')
                        .map((e) => e.isNotEmpty ? e[0] : '')
                        .take(2)
                        .join()
                        .toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fullName.isEmpty ? username : fullName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 1),
                      Text(
                        '$email  •  @${username.isEmpty ? '-' : username}',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: roles
                            .map((r) => Chip(
                                  label: Text(r),
                                  visualDensity: VisualDensity.compact,
                                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit identitas',
                  icon: const Icon(Icons.edit),
                  onPressed: openEditIdentitySheet,
                ),
              ],
            ),

            // Akun
            _sectionTitle('Akun'),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            _readonlyField('Email', email, canCopy: true),

            // Data Personal
            _sectionTitle('Data Personal'),
            _editableField(
              label: 'Nomor HP',
              controller: phoneC,
              editing: editingPhone,
              keyboardType: TextInputType.phone,
              onEdit: () => setState(() => editingPhone = true),
              onSave: () async {
                final newPhone = phoneC.text.trim();
                final messenger = ScaffoldMessenger.of(context);
                try {
                  setState(() => _loading = true);
                  await repo.updatePhone(phone: newPhone);
                  setState(() {
                    phone = newPhone;
                    editingPhone = false;
                  });
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text('Gagal menyimpan nomor HP: $e')),
                  );
                } finally {
                  if (mounted) setState(() => _loading = false);
                }
              },
              onCancel: () => setState(() {
                phoneC.text = phone;
                editingPhone = false;
              }),
            ),

            // Preferensi
            _sectionTitle('Preferensi'),
            ListTile(
              dense: true,
              visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
              title: Text('Tema', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'system', label: Text('Sistem'), icon: Icon(Icons.settings_suggest)),
                    ButtonSegment(value: 'light', label: Text('Terang'), icon: Icon(Icons.light_mode)),
                    ButtonSegment(value: 'dark', label: Text('Gelap'), icon: Icon(Icons.dark_mode)),
                  ],
                  selected: {themePref},
                  onSelectionChanged: (v) async {
                    final selected = v.first;
                    setState(() => themePref = selected);
                    final controller = ThemeController.instance;
                    switch (selected) {
                      case 'light':
                        await controller.setMode(ThemeMode.light);
                        break;
                      case 'dark':
                        await controller.setMode(ThemeMode.dark);
                        break;
                      default:
                        await controller.setMode(ThemeMode.system);
                    }
                  },
                ),
              ),
            ),
            const ListTile(
              dense: true,
              visualDensity: VisualDensity(horizontal: 0, vertical: -2),
              title: Text('Bahasa', style: TextStyle(color: Colors.black54)),
              subtitle: Text('id-ID'),
            ),

            // Keamanan
            _sectionTitle('Keamanan'),
            ListTile(
              dense: true,
              visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
              leading: const Icon(Icons.lock),
              title: const Text('Ubah Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Ubah Password'),
                    content: _ChangePasswordDialog(onSubmit: (curr, next) async {
                      final navigator = Navigator.of(ctx);
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        setState(() => _loading = true);
                        await repo.changePassword(currentPassword: curr, newPassword: next);
                        if (!mounted) return;
                        navigator.pop();
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Password berhasil diubah')),
                        );
                      } catch (e) {
                        // Map common errors
                        final msg = e.toString();
                        String ui = 'Gagal mengubah password: $e';
                        if (msg.contains('password') && msg.contains('salah')) {
                          ui = 'Password saat ini salah.';
                        }
                        messenger.showSnackBar(
                          SnackBar(content: Text(ui)),
                        );
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    }),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
                    ],
                  ),
                );
              },
            ),

            // Tentang
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
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final Future<void> Function(String current, String next) onSubmit;
  const _ChangePasswordDialog({required this.onSubmit});
  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final currC = TextEditingController();
  final nextC = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool submitting = false;

  @override
  void dispose() {
    currC.dispose();
    nextC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: currC,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password saat ini'),
            validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: nextC,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password baru'),
            validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(
                onPressed: submitting ? null : () async {
                  if (!formKey.currentState!.validate()) return;
                  setState(() => submitting = true);
                  try {
                    await widget.onSubmit(currC.text, nextC.text);
                  } finally {
                    if (mounted) setState(() => submitting = false);
                  }
                },
                child: const Text('Simpan'),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ],
          ),
        ],
      ),
    );
  }
}
