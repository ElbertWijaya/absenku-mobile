import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../attendance/data/attendance_repository.dart';

class QrScanCheckInScreen extends StatefulWidget {
  const QrScanCheckInScreen({super.key});

  @override
  State<QrScanCheckInScreen> createState() => _QrScanCheckInScreenState();
}

class _QrScanCheckInScreenState extends State<QrScanCheckInScreen> with WidgetsBindingObserver {
  final repo = AttendanceRepository();
  bool _processing = false;
  String? _result;
  late final MobileScannerController _controller;
  String? _cameraError;
  // Track app lifecycle to pause/resume camera

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [BarcodeFormat.qrCode],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Pause camera when app not active
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      // Resume camera when returning
      _controller.start();
    }
  }

  Future<void> _onDetect(BarcodeCapture cap) async {
    if (_processing) return;
    if (cap.barcodes.isEmpty) return;
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
      appBar: AppBar(
        title: const Text('Scan QR - Check In'),
        actions: [
          IconButton(
            tooltip: 'Flash',
            onPressed: () async {
              try { await _controller.toggleTorch(); } catch (_) {}
              setState(() {});
            },
            icon: const Icon(Icons.flash_on),
          ),
          IconButton(
            tooltip: 'Switch Camera',
            onPressed: () async {
              try { await _controller.switchCamera(); } catch (_) {}
              setState(() {});
            },
            icon: const Icon(Icons.cameraswitch),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: MobileScanner(
                  controller: _controller,
                  fit: BoxFit.cover,
                  onDetect: _onDetect,
                  errorBuilder: (context, error, child) {
                    _cameraError = error.toString();
                    return Container(
                      color: Colors.black,
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'Kamera tidak tersedia atau gagal diinisialisasi.',
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            if (_cameraError != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _cameraError!,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () async {
                                try { await _controller.start(); } catch (_) {}
                                setState(() { _cameraError = null; });
                              },
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_result != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_result!),
                ),
            ],
          ),
          if (_processing)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'Memproses check-in...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
