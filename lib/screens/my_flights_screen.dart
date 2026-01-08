/// 📋 TELA MEUS VOOS
/// 
/// Lista voos salvos + Exportar CSV

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../data/database/flight_database.dart';
import '../data/repositories/telemetry_point_repository.dart';

class MyFlightsScreen extends ConsumerStatefulWidget {
  const MyFlightsScreen({super.key});

  @override
  ConsumerState<MyFlightsScreen> createState() => _MyFlightsScreenState();
}

class _MyFlightsScreenState extends ConsumerState<MyFlightsScreen> {
  List<Map<String, dynamic>> _flights = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  Future<void> _loadFlights() async {
    setState(() => _loading = true);
    
    final flightIds = await FlightDatabase.listAllFlights();
    final flights = <Map<String, dynamic>>[];
    
    for (final id in flightIds) {
      final info = await FlightDatabase.getDatabaseInfo(id);
      if (info != null) flights.add(info);
    }
    
    // Ordenar por mais recente
    flights.sort((a, b) => ((b['startTime'] ?? 0) as int).compareTo((a['startTime'] ?? 0) as int));
    
    setState(() {
      _flights = flights;
      _loading = false;
    });
  }

  Future<void> _exportCsv(String flightId) async {
    final repo = TelemetryPointRepository();
    final points = await repo.getAllByFlight(flightId);
    
    if (points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum ponto para exportar')),
      );
      return;
    }

    // Gerar CSV
    final buffer = StringBuffer();
    buffer.writeln('timestamp,lat,lng,altitude,velocity,heading,pitch,roll,data_quality');
    
    for (final p in points) {
      buffer.writeln(
        '${p.timestamp},${p.lat},${p.lng},${p.altitude},${p.velocity},'
        '${p.heading},${p.imuPitch},${p.imuRoll},${p.dataQuality}'
      );
    }

    // Salvar arquivo
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/flight_$flightId.csv');
    await file.writeAsString(buffer.toString());

    // Compartilhar
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Voo $flightId',
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
    );
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return '-';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '-';
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    return '${m}min ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Voos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFlights,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _flights.isEmpty
              ? const Center(child: Text('Nenhum voo salvo'))
              : ListView.builder(
                  itemCount: _flights.length,
                  itemBuilder: (ctx, i) {
                    final f = _flights[i];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: Icon(
                          f['status'] == 'completed' 
                              ? Icons.flight_land 
                              : Icons.flight_takeoff,
                          color: f['status'] == 'completed' 
                              ? Colors.green 
                              : Colors.orange,
                        ),
                        title: Text('Voo ${(f['flightId'] as String).substring(0, 8)}...'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('📅 ${_formatDate(f['startTime'])}'),
                            Text('⏱️ ${_formatDuration(f['durationSeconds'])} • ${f['totalPoints']} pts'),
                            Text('📊 ${((f['sizeBytes'] ?? 0) / 1024).toStringAsFixed(1)} KB'),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.download, color: Colors.blue),
                          onPressed: () => _exportCsv(f['flightId']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
