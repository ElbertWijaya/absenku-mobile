import 'package:flutter/material.dart';
import '../../auth/data/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController(text: 'admin@example.com');
  final passC = TextEditingController(text: 'Admin@123');
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String? error;

  final repo = AuthRepository();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await repo.login(emailC.text.trim(), passC.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() {
        error = 'Login gagal. Pastikan server berjalan dan kredensial benar. ($e)';
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: emailC,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Email wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passC,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(error!, style: const TextStyle(color: Colors.red)),
                    ),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loading ? null : _login,
                      child: loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator())
                          : const Text('Masuk'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Gunakan akun admin untuk uji awal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}