import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../qr/data/qr_repository.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  String? _token;
  DateTime? _expiresAt;
  String? _workDate;
  bool _loading = false;
  String? _error;
  final repo = QrRepository();

  Future<void> _loadActive() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await repo.getActive();
      setState(() {
        _token = data['token'] as String?;
        _workDate = data['work_date'] as String?;
        final exp = data['expires_at'] as String?;
        _expiresAt = exp != null ? DateTime.tryParse(exp) : null;
      });
    } catch (e) {
      setState(() => _error = 'Gagal memuat QR aktif: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _issue() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await repo.issue();
      setState(() {
        _token = data['token'] as String?;
        _workDate = data['work_date'] as String?;
        final exp = data['expires_at'] as String?;
        _expiresAt = exp != null ? DateTime.tryParse(exp) : null;
      });
      final reused = data['reused'] == true;
      if (mounted && reused) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (ctx) => AlertDialog(
            title: const Text('Menggunakan Ulang QR'),
            content: const Text('QR untuk hari ini sudah tersedia, menampilkan QR yang sama.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _error = 'Gagal generate QR: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Auto-load active QR on screen open
    _loadActive();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('QR Absensi Hari Ini')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),

              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: CircularProgressIndicator(),
                        )
                      else if (_token != null)
                        Column(
                          children: [
                            QrImageView(
                              data: _token!,
                              size: 240,
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                if (_workDate != null)
                                  Chip(
                                    avatar: const Icon(Icons.today, size: 18),
                                    label: Text('Tanggal: $_workDate'),
                                  ),
                                if (_expiresAt != null)
                                  Chip(
                                    avatar: const Icon(Icons.timer, size: 18),
                                    label: Text('Berlaku s/d: ${dateFmt.format(_expiresAt!.toLocal())}')
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tunjukkan QR ini kepada karyawan untuk scan. Token tidak ditampilkan demi keamanan.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: const [
                              Icon(Icons.qr_code_2, size: 72, color: Colors.black26),
                              SizedBox(height: 12),
                              Text('Belum ada QR untuk hari ini'),
                              SizedBox(height: 4),
                              Text('Tekan Generate untuk membuat QR harian', style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _issue,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate/Re-use'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
