import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../attendance/data/attendance_repository.dart';

class QrScanCheckInScreen extends StatefulWidget {
  final VoidCallback? onSuccessNavigateHome;
  const QrScanCheckInScreen({super.key, this.onSuccessNavigateHome});

  @override
  State<QrScanCheckInScreen> createState() => _QrScanCheckInScreenState();
}

class _QrScanCheckInScreenState extends State<QrScanCheckInScreen>
    with WidgetsBindingObserver {
  final repo = AttendanceRepository();
  late final MobileScannerController _controller;
  StreamSubscription<Object?>? _subscription;
  bool _processing = false;
  bool _handled = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(autoStart: false);
    WidgetsBinding.instance.addObserver(this);
    // Subscribe to barcodes when starting (we start in initState end)
    _subscription = _controller.barcodes.listen(_onBarcode);
    // Start the camera explicitly to avoid surprises
    unawaited(_controller.start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Don't try to control before permissions are granted
    if (!_controller.value.hasCameraPermission) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _subscription ??= _controller.barcodes.listen(_onBarcode);
        unawaited(_controller.start());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(_controller.stop());
        break;
    }
  }

  void _onBarcode(BarcodeCapture capture) async {
    if (_processing || _handled) return;
    final first = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final code = first?.rawValue;
    if (code == null || code.isEmpty) return;
    if (!mounted) return;
    setState(() {
      _processing = true;
      _errorText = null;
    });
    try {
      // 1) Prevent duplicate attendance by checking today's logs first
      try {
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final logs = await repo.myLogs(start: today, end: today);
        if (logs.isNotEmpty) {
          _handled = true;
          await _controller.stop();
          if (!mounted) return;
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Peringatan'),
              content: const Text(
                'Anda sudah melakukan absensi hari ini. Silahkan lakukan absensi lagi di hari selanjutnya.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          if (!mounted) return;
          if (widget.onSuccessNavigateHome != null) {
            widget.onSuccessNavigateHome!.call();
          } else {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
          return; // stop here, no check-in call
        }
      } catch (_) {
        // If pre-check fails, continue to server-side enforcement below
      }

      // 2) Proceed to check-in; server should also prevent duplicates
      await repo.checkIn(qrToken: code);
      _handled = true;
      await _controller.stop(); // release camera before navigation
      if (!mounted) return;
      // Navigate immediately without showing an intermediate screen
      if (widget.onSuccessNavigateHome != null) {
        widget.onSuccessNavigateHome!.call();
      } else {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      // Detect duplicate/already-checked scenarios and show the requested warning
      if (e is DioException) {
        final status = e.response?.statusCode;
        final data = e.response?.data;
        final msg = () {
          if (data is Map) {
            final m = data['message'] ?? data['error'] ?? data['msg'];
            return m?.toString();
          }
          if (data is String) return data;
          return null;
        }();
        final lower = (msg ?? '').toLowerCase();
        final looksDuplicate = status == 409 ||
            lower.contains('already') ||
            lower.contains('sudah') ||
            lower.contains('duplicate') ||
            lower.contains('hari ini');

        if (looksDuplicate) {
          _handled = true;
          // Stop camera and warn the user, then leave immediately
          await _controller.stop();
          if (!mounted) return;
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Peringatan'),
              content: const Text(
                'Anda sudah melakukan absensi hari ini. Silahkan lakukan absensi lagi di hari selanjutnya.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          if (!mounted) return;
          if (widget.onSuccessNavigateHome != null) {
            widget.onSuccessNavigateHome!.call();
          } else {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        _processing = false;
        _errorText = 'Gagal check-in: $e';
      });
      // allow trying again for non-duplicate errors
      await _controller.start();
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
              await _controller.toggleTorch();
              setState(() {});
            },
            icon: const Icon(Icons.flash_on),
          ),
          IconButton(
            tooltip: 'Switch Camera',
            onPressed: () async {
              await _controller.switchCamera();
              setState(() {});
            },
            icon: const Icon(Icons.cameraswitch),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onBarcode,
                ),
                // Simple overlay similar to previous
                IgnorePointer(
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      height: MediaQuery.of(context).size.width * 0.75,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 4,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_processing)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('Memproses check-in...'),
                ],
              ),
            ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
        ],
      ),
    );
  }
}
