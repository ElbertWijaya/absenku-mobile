import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../attendance/data/attendance_repository.dart';

class QrScanCheckInScreen extends StatefulWidget {
  const QrScanCheckInScreen({super.key});

  @override
  State<QrScanCheckInScreen> createState() => _QrScanCheckInScreenState();
}

class _QrScanCheckInScreenState extends State<QrScanCheckInScreen> {
  final repo = AttendanceRepository();
  bool _processing = false;
  String? _result;

  Future<void> _onDetect(BarcodeCapture cap) async {
    if (_processing) return;
    final code = cap.barcodes.first.rawValue;
    if (code == null) return;

    setState(() {
      _processing = true;
      _result = null;
    });

    try {
      final data = await repo.checkIn(qrToken: code);
      setState(() => _result = 'Sukses check-in: ${data['status']}');
      if (mounted) {
        // Tampilkan info singkat lalu kembali ke Home
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        Navigator.of(context).pop(); // kembali ke halaman sebelumnya (Home)
      }
    } catch (e) {
      setState(() => _result = 'Gagal check-in: $e');
    } finally {
      setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR - Check In')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: _onDetect,
            ),
          ),
          if (_result != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_result!),
            ),
        ],
      ),
    );
  }
}
