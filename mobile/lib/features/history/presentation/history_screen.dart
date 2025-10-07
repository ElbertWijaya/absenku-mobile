import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/dio_client.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> logs = [];
  bool loading = true;
  String? error;

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final dio = DioClient().dio;
      final res = await dio.get('/attendance/my');
      setState(() { logs = res.data as List<dynamic>; });
    } catch (e) {
      setState(() { error = 'Gagal memuat: $e'; });
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Kehadiran')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : ListView.separated(
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final item = logs[i] as Map<String, dynamic>;
                    return ListTile(
                      title: Text('Tanggal: ${item['work_date']}'),
                      subtitle: Text('Check-in: ${item['check_in_at'] ?? '-'}'),
                      trailing: Text(item['status']?.toString() ?? ''),
                    );
                  },
                ),
    );
  }
}