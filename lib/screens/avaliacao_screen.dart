import 'package:flutter/material.dart';
import 'connection_screen.dart';

class AvaliacaoScreen extends StatefulWidget {
  final String nomeInstrutor;
  final String nomeAluno;
  final Duration duracao;
  final double velocidadeMax;
  final double altitudeMax;

  const AvaliacaoScreen({
    Key? key,
    required this.nomeInstrutor,
    required this.nomeAluno,
    required this.duracao,
    required this.velocidadeMax,
    required this.altitudeMax,
  }) : super(key: key);

  @override
  State<AvaliacaoScreen> createState() => _AvaliacaoScreenState();
}

class _AvaliacaoScreenState extends State<AvaliacaoScreen> {
  int _nota = 0;
  final TextEditingController _observacoesController = TextEditingController();
  final int _maxCaracteres = 500;

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }

  void _salvarAvaliacao() {
    if (_nota == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Selecione uma nota antes de salvar!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // TODO: Aqui vai salvar no banco de dados no futuro
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Avaliação salva com sucesso!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Navegar para tela de conexão
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ConnectionScreen()),
        (route) => false,
      );
    });
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
                  colors: [Colors.purple.shade800, Colors.purple.shade600],
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.rate_review, color: Colors.white, size: isLandscape ? 32 : 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AVALIAÇÃO DA AULA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLandscape ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Icon(Icons.edit_note, color: Colors.white, size: isLandscape ? 32 : 28),
                ],
              ),
            ),

            // Conteúdo
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isLandscape ? 20 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card de informações
                    Container(
                      padding: EdgeInsets.all(isLandscape ? 16 : 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade400, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            '👨‍✈️ Instrutor:',
                            widget.nomeInstrutor,
                            isLandscape,
                          ),
                          SizedBox(height: isLandscape ? 10 : 8),
                          _buildInfoRow(
                            '👤 Aluno:',
                            widget.nomeAluno,
                            isLandscape,
                          ),
                          SizedBox(height: isLandscape ? 10 : 8),
                          _buildInfoRow(
                            '📅 Data:',
                            _getDataFormatada(),
                            isLandscape,
                          ),
                          SizedBox(height: isLandscape ? 10 : 8),
                          _buildInfoRow(
                            '⏱️ Duração:',
                            _formatDuracao(widget.duracao),
                            isLandscape,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isLandscape ? 24 : 20),

                    // Sistema de estrelas
                    Container(
                      padding: EdgeInsets.all(isLandscape ? 20 : 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber, width: 2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '⭐ NOTA DA AULA',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: isLandscape ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: isLandscape ? 16 : 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () => setState(() => _nota = index + 1),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isLandscape ? 8 : 6,
                                  ),
                                  child: Icon(
                                    index < _nota ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: isLandscape ? 56 : 48,
                                  ),
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: isLandscape ? 12 : 8),
                          Text(
                            _nota == 0 ? 'Toque para avaliar' : '$_nota/5 estrelas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isLandscape ? 16 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isLandscape ? 24 : 20),

                    // Campo de observações
                    Container(
                      padding: EdgeInsets.all(isLandscape ? 16 : 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade400, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.notes, color: Colors.blue.shade400, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '📝 OBSERVAÇÕES',
                                style: TextStyle(
                                  color: Colors.blue.shade400,
                                  fontSize: isLandscape ? 16 : 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isLandscape ? 12 : 10),
                          TextField(
                            controller: _observacoesController,
                            maxLines: isLandscape ? 6 : 5,
                            maxLength: _maxCaracteres,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isLandscape ? 15 : 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Digite aqui suas observações sobre a aula...\n\n'
                                  'Exemplos:\n'
                                  '• Desempenho do aluno\n'
                                  '• Pontos a melhorar\n'
                                  '• Comentários gerais',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: isLandscape ? 14 : 13,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade900,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            onChanged: (value) => setState(() {}),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isLandscape ? 24 : 20),

                    // Botões
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: isLandscape ? 56 : 48,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.arrow_back,
                                size: isLandscape ? 22 : 20,
                              ),
                              label: Text(
                                'VOLTAR',
                                style: TextStyle(
                                  fontSize: isLandscape ? 16 : 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isLandscape ? 16 : 12),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: isLandscape ? 56 : 48,
                            child: ElevatedButton.icon(
                              onPressed: _salvarAvaliacao,
                              icon: Icon(
                                Icons.check_circle,
                                size: isLandscape ? 24 : 22,
                              ),
                              label: Text(
                                'SALVAR AVALIAÇÃO',
                                style: TextStyle(
                                  fontSize: isLandscape ? 16 : 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
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
                        ),
                      ],
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

  Widget _buildInfoRow(String label, String value, bool isLandscape) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: isLandscape ? 14 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isLandscape ? 15 : 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuracao(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(d.inHours);
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String _getDataFormatada() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }
}