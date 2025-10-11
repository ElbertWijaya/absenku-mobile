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
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm:ss');
    return Scaffold(
      appBar: AppBar(title: const Text('QR Generator')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _loadActive,
                    child: const Text('Load Active'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _loading ? null : _issue,
                    child: const Text('Generate Baru'),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              if (_token != null) ...[
                Center(
                  child: QrImageView(
                    data: _token!,
                    size: 220,
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText('Token: $_token'),
                if (_workDate != null) Text('Tanggal Kerja: $_workDate'),
                if (_expiresAt != null)
                  Text('Expires: ${dateFmt.format(_expiresAt!.toLocal())}'),
              ] else
                const Text('Belum ada token. Muat aktif atau generate baru.'),
            ],
          ),
        ),
      ),
    );
  }
}
