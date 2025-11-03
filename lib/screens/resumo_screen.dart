import 'package:flutter/material.dart';
import 'connection_screen.dart';
import 'avaliacao_screen.dart';

class ResumoScreen extends StatelessWidget {
  final String nomeInstrutor;
  final String nomeAluno;
  final Duration duracao;
  final double velocidadeMax;
  final double altitudeMax;
  final double pitchMax;
  final double pitchMin;
  final double rollMax;
  final double rollMin;
  final double varioMax;
  final double varioMin;
  final double temperaturaMax;
  final double temperaturaMin;

  const ResumoScreen({
    Key? key,
    this.nomeInstrutor = 'Instrutor',
    this.nomeAluno = 'Aluno',
    required this.duracao,
    required this.velocidadeMax,
    required this.altitudeMax,
    required this.pitchMax,
    required this.pitchMin,
    required this.rollMax,
    required this.rollMin,
    required this.varioMax,
    required this.varioMin,
    required this.temperaturaMax,
    required this.temperaturaMin,
  }) : super(key: key);

  String _formatDuracao(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(d.inHours);
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.blue.shade600],
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.summarize, color: Colors.white, size: isLandscape ? 32 : 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'RESUMO DO VOO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLandscape ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Icon(Icons.check_circle, color: Colors.green, size: isLandscape ? 32 : 28),
                ],
              ),
            ),

            // Conteúdo
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isLandscape ? 16 : 12),
                child: Column(
                  children: [
                    // Cards principais (Duração e Hobbs)
                    Row(
                      children: [
                        Expanded(
                          child: _buildMainCard(
                            '⏱️ DURAÇÃO',
                            _formatDuracao(duracao),
                            'Tempo de voo',
                            Colors.blue,
                            isLandscape,
                          ),
                        ),
                        SizedBox(width: isLandscape ? 16 : 12),
                        Expanded(
                          child: _buildMainCard(
                            '🕐 HOBBS',
                            _formatDuracao(duracao),
                            'Tempo motor',
                            Colors.indigo,
                            isLandscape,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isLandscape ? 16 : 12),

                    // Grid de estatísticas
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: isLandscape ? 16 : 12,
                      mainAxisSpacing: isLandscape ? 16 : 12,
                      childAspectRatio: isLandscape ? 1.8 : 1.5,
                      children: [
                        _buildStatCard(
                          '⚡ Velocidade Máx',
                          '${velocidadeMax.toStringAsFixed(1)}',
                          'km/h',
                          Colors.orange,
                          Icons.speed,
                          isLandscape,
                        ),
                        _buildStatCard(
                          '✈️ Altitude Máx',
                          '${altitudeMax.toStringAsFixed(0)}',
                          'm',
                          Colors.cyan,
                          Icons.height,
                          isLandscape,
                        ),
                        _buildStatCard(
                          '📐 Pitch Máx',
                          '${pitchMax.toStringAsFixed(1)}°',
                          '(nariz cima)',
                          Colors.green,
                          Icons.arrow_upward,
                          isLandscape,
                        ),
                        _buildStatCard(
                          '📐 Pitch Mín',
                          '${pitchMin.toStringAsFixed(1)}°',
                          '(nariz baixo)',
                          Colors.red,
                          Icons.arrow_downward,
                          isLandscape,
                        ),
                        _buildStatCard(
                          '🔄 Roll Direita',
                          '${rollMax.toStringAsFixed(1)}°',
                          '(inclinação)',
                          Colors.teal,
                          Icons.rotate_right,
                          isLandscape,
                        ),
                        _buildStatCard(
                          '🔄 Roll Esquerda',
                          '${rollMin.abs().toStringAsFixed(1)}°',
                          '(inclinação)',
                          Colors.purple,
                          Icons.rotate_left,
                          isLandscape,
                        ),
                        _buildStatCard(
                          '⬆️ Subida Máx',
                          '${varioMax.toStringAsFixed(1)}',
                          'm/s',
                          Colors.lightGreen,
                          Icons.trending_up,
                          isLandscape,
                        ),
                        _buildStatCard(
                          '⬇️ Descida Máx',
                          '${varioMin.abs().toStringAsFixed(1)}',
                          'm/s',
                          Colors.deepOrange,
                          Icons.trending_down,
                          isLandscape,
                        ),
                        _buildStatCard(
                          '🌡️ Temp Máx',
                          '${temperaturaMax.toStringAsFixed(1)}',
                          '°C',
                          Colors.red.shade700,
                          Icons.thermostat,
                          isLandscape,
                        ),
                        _buildStatCard(
                          '❄️ Temp Mín',
                          '${temperaturaMin.toStringAsFixed(1)}',
                          '°C',
                          Colors.blue.shade400,
                          Icons.ac_unit,
                          isLandscape,
                        ),
                      ],
                    ),

                    SizedBox(height: isLandscape ? 20 : 16),

                    // Botão Avaliar Aula
                    SizedBox(
                      width: double.infinity,
                      height: isLandscape ? 56 : 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AvaliacaoScreen(
                                nomeInstrutor: nomeInstrutor,
                                nomeAluno: nomeAluno,
                                duracao: duracao,
                                velocidadeMax: velocidadeMax,
                                altitudeMax: altitudeMax,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.rate_review, size: isLandscape ? 24 : 20),
                        label: Text(
                          'AVALIAR AULA',
                          style: TextStyle(
                            fontSize: isLandscape ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),

                    SizedBox(height: isLandscape ? 16 : 12),

                    // Botão Nova Conexão
                    SizedBox(
                      width: double.infinity,
                      height: isLandscape ? 56 : 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ConnectionScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: Icon(Icons.refresh, size: isLandscape ? 24 : 20),
                        label: Text(
                          'NOVA CONEXÃO',
                          style: TextStyle(
                            fontSize: isLandscape ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(
    String titulo,
    String valor,
    String subtitulo,
    Color cor,
    bool isLandscape,
  ) {
    return Container(
      padding: EdgeInsets.all(isLandscape ? 16 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.lerp(cor, Colors.black, 0.2)!,
            cor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            titulo,
            style: TextStyle(
              color: Colors.white,
              fontSize: isLandscape ? 14 : 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isLandscape ? 8 : 6),
          Text(
            valor,
            style: TextStyle(
              color: Colors.white,
              fontSize: isLandscape ? 32 : 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isLandscape ? 4 : 2),
          Text(
            subtitulo,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isLandscape ? 12 : 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String titulo,
    String valor,
    String unidade,
    Color cor,
    IconData icone,
    bool isLandscape,
  ) {
    return Container(
      padding: EdgeInsets.all(isLandscape ? 12 : 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cor, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, color: cor, size: isLandscape ? 24 : 20),
          SizedBox(height: isLandscape ? 6 : 4),
          Text(
            titulo,
            style: TextStyle(
              color: cor,
              fontSize: isLandscape ? 11 : 9,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isLandscape ? 4 : 2),
          Text(
            valor,
            style: TextStyle(
              color: Colors.white,
              fontSize: isLandscape ? 20 : 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            unidade,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: isLandscape ? 10 : 9,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}