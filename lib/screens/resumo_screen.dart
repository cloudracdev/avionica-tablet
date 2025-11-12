import 'package:flutter/material.dart';
import '../models/flight_stats.dart';

/// 📊 Tela de Resumo do Voo
/// Exibe estatísticas finais após o voo
class ResumoScreen extends StatelessWidget {
  final FlightStats stats;

  const ResumoScreen({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('📊 Resumo do Voo'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⏱️ Duração
            _buildStatCard(
              '⏱️ DURAÇÃO',
              _formatDuration(stats.duration),
              Colors.blue,
            ),
            const SizedBox(height: 16),

            // 🚀 Velocidade
            _buildStatCard(
              '🚀 VELOCIDADE MÁXIMA',
              '${stats.velocidadeMax.toStringAsFixed(1)} km/h',
              Colors.green,
            ),
            const SizedBox(height: 16),

            // 🏔️ Altitude
            _buildStatCard(
              '🏔️ ALTITUDE MÁXIMA',
              '${stats.altitudeMax.toStringAsFixed(1)} m',
              Colors.orange,
            ),
            const SizedBox(height: 16),

            // ✈️ Atitude
            _buildDoubleStatCard(
              '✈️ PITCH',
              'Mínimo: ${stats.pitchMin.toStringAsFixed(1)}°',
              'Máximo: ${stats.pitchMax.toStringAsFixed(1)}°',
              Colors.purple,
            ),
            const SizedBox(height: 16),

            _buildDoubleStatCard(
              '✈️ ROLL',
              'Mínimo: ${stats.rollMin.toStringAsFixed(1)}°',
              'Máximo: ${stats.rollMax.toStringAsFixed(1)}°',
              Colors.pink,
            ),
            const SizedBox(height: 16),

            // 📈 Variômetro
            _buildDoubleStatCard(
              '📈 VARIÔMETRO',
              'Descida: ${stats.varioMin.toStringAsFixed(2)} m/s',
              'Subida: ${stats.varioMax.toStringAsFixed(2)} m/s',
              Colors.teal,
            ),
            const SizedBox(height: 16),

            // 🌡️ Temperatura
            _buildDoubleStatCard(
              '🌡️ TEMPERATURA',
              'Mínima: ${stats.temperaturaMin.toStringAsFixed(1)}°C',
              'Máxima: ${stats.temperaturaMax.toStringAsFixed(1)}°C',
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoubleStatCard(
    String title,
    String value1,
    String value2,
    Color color,
  ) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value2,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}