/// 📋 TELA MEUS VOOS
/// 
/// Lista voos salvos + Exportar CSV + Descartar

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum ponto para exportar')),
        );
      }
      return;
    }

    // Gerar CSV com TODOS os campos e unidades de aviação
    final buffer = StringBuffer();
    buffer.writeln(
      'timestamp,lat,lng,'
      'altitude_ft,velocity_kts,vertical_speed_fpm,'
      'heading,pitch,roll,'
      'accel_x,accel_y,gyro_z,'
      'temperature_c,pressure_pa,data_quality'
    );
    
    for (final p in points) {
      // Conversões para unidades de aviação
      final altitudeFt = (p.altitude ?? 0) * 3.28084;
      final velocityKts = (p.velocity ?? 0) / 1.852;
      final varioFpm = (p.verticalSpeed ?? 0) * 196.85;
      
      buffer.writeln(
        '${p.timestamp},'
        '${p.lat},'
        '${p.lng},'
        '${altitudeFt.toStringAsFixed(1)},'
        '${velocityKts.toStringAsFixed(1)},'
        '${varioFpm.toStringAsFixed(1)},'
        '${p.heading ?? 0},'
        '${p.imuPitch ?? 0},'
        '${p.imuRoll ?? 0},'
        '${p.accelX ?? 0},'
        '${p.accelY ?? 0},'
        '${p.gyroZ ?? 0},'
        '${p.baroTemperature ?? 0},'
        '${p.baroPressure ?? 0},'
        '${p.dataQuality}'
      );
    }

    // Salvar arquivo
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/flight_$flightId.csv');
    await file.writeAsString(buffer.toString());

    // Compartilhar
    if (mounted) {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Voo $flightId',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
      );
    }
  }

  Future<void> _discardFlight(String flightId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🗑️ Descartar Voo?'),
        content: const Text(
          'Todos os dados de telemetria serão apagados.\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('DESCARTAR'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FlightDatabase.delete(flightId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Voo descartado')),
        );
        _loadFlights();
      }
    }
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
                    final flightId = f['flightId'] as String;
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
                        title: Text('Voo ${flightId.substring(0, 8)}...'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('📅 ${_formatDate(f['startTime'])}'),
                            Text('⏱️ ${_formatDuration(f['durationSeconds'])} • ${f['totalPoints']} pts'),
                            Text('📊 ${((f['sizeBytes'] ?? 0) / 1024).toStringAsFixed(1)} KB'),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.download, color: Colors.blue),
                              onPressed: () => _exportCsv(flightId),
                              tooltip: 'Exportar CSV',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _discardFlight(flightId),
                              tooltip: 'Descartar',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
