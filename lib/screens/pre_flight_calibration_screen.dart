import 'package:flutter/material.dart';
import '../utils/websocket_service.dart';
import '../utils/calibration_service.dart';
import 'sixpack_screen.dart';

class PreFlightCalibrationScreen extends StatefulWidget {
  final WebSocketService wsService;

  const PreFlightCalibrationScreen({
    Key? key,
    required this.wsService,
  }) : super(key: key);

  @override
  State<PreFlightCalibrationScreen> createState() => _PreFlightCalibrationScreenState();
}

class _PreFlightCalibrationScreenState extends State<PreFlightCalibrationScreen> {
  final CalibrationService _calibrationService = CalibrationService();
  final TextEditingController _bussola = TextEditingController();

  // Dados recebidos do ESP32
  double _currentHeading = 0.0;
  double _currentPitch = 0.0;
  double _currentRoll = 0.0;
  double _currentAltitude = 0.0;
  bool _dadosRecebidos = false;

  // Estados dos checkboxes
  bool _aviaoAlinhado = false;
  bool _zerarPitchRoll = false;
  bool _zerarAltitude = false;

  @override
  void initState() {
    super.initState();
    _escutarDados();
  }

  void _escutarDados() {
    widget.wsService.dataStream.listen((data) {
      if (!mounted) return;
      
      setState(() {
        _currentHeading = data['heading']?.toDouble() ?? 0.0;
        _currentPitch = data['pitch']?.toDouble() ?? 0.0;
        _currentRoll = data['roll']?.toDouble() ?? 0.0;
        _currentAltitude = data['altitude']?.toDouble() ?? 0.0;
        _dadosRecebidos = true;
      });
    });
  }

  void _aplicarCalibracoes() {
    // Calibrar bússola se valor digitado
    if (_bussola.text.isNotEmpty) {
      double realHeading = double.tryParse(_bussola.text) ?? 0.0;
      _calibrationService.calibrateHeading(realHeading, _currentHeading);
    }

    // Zerar pitch + roll se marcado
    if (_zerarPitchRoll) {
      _calibrationService.zeroPitch(_currentPitch);
      _calibrationService.zeroRoll(_currentRoll);
    }

    // Zerar altitude se marcado
    if (_zerarAltitude) {
      _calibrationService.zeroAltitude(_currentAltitude);
    }

    // Navegar para sixpack com calibração aplicada
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SixPackScreen(
          wsService: widget.wsService,
          calibrationService: _calibrationService,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bussola.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Aguardar primeiros dados
    if (!_dadosRecebidos) {
      return Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.blue),
              const SizedBox(height: 20),
              Text(
                '📡 Aguardando dados do ESP32...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: const Text('✈️ Calibração Pré-Voo'),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card principal
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.settings, color: Colors.blue, size: 48),
                              const SizedBox(height: 8),
                              const Text(
                                'CHECKLIST PRÉ-VOO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Divider(color: Colors.grey, height: 1),
                        const SizedBox(height: 20),

                        // ✅ PRIMEIRO CHECKBOX (sempre disponível)
                        _buildCheckbox(
                          title: 'Avião alinhado na pista e hardware OK',
                          subtitle: 'Confirme que a aeronave está em posição de decolagem\ne os sensores estão funcionando corretamente',
                          value: _aviaoAlinhado,
                          onChanged: (val) => setState(() => _aviaoAlinhado = val ?? false),
                          enabled: true,
                          icon: Icons.airplanemode_active,
                        ),

                        const SizedBox(height: 20),

                        // 🧭 INPUT BÚSSOLA (só aparece após primeiro check)
                        if (_aviaoAlinhado) ...[
                          _buildBussolaInput(),
                          const SizedBox(height: 20),
                        ],

                        // 🔄 CHECKBOX PITCH + ROLL (só aparece após primeiro check)
                        if (_aviaoAlinhado) ...[
                          _buildCheckbox(
                            title: 'Zerar Pitch + Roll',
                            subtitle: 'Pitch: ${_currentPitch.toStringAsFixed(1)}° | Roll: ${_currentRoll.toStringAsFixed(1)}°',
                            value: _zerarPitchRoll,
                            onChanged: (val) => setState(() => _zerarPitchRoll = val ?? false),
                            enabled: true,
                            icon: Icons.rotate_90_degrees_ccw,
                          ),
                          const SizedBox(height: 20),
                        ],

                        // 📏 CHECKBOX ALTITUDE (só aparece após primeiro check)
                        if (_aviaoAlinhado) ...[
                          _buildCheckbox(
                            title: 'Zerar Altitude (QNH)',
                            subtitle: 'Altitude atual: ${_currentAltitude.toStringAsFixed(1)} m',
                            value: _zerarAltitude,
                            onChanged: (val) => setState(() => _zerarAltitude = val ?? false),
                            enabled: true,
                            icon: Icons.height,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botão CONTINUAR (só habilitado após primeiro check)
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _aviaoAlinhado ? _aplicarCalibracoes : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _aviaoAlinhado ? Colors.green : Colors.grey.shade700,
                    disabledBackgroundColor: Colors.grey.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _aviaoAlinhado ? 4 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: _aviaoAlinhado ? Colors.white : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'CONTINUAR PARA VOO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: _aviaoAlinhado ? Colors.white : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool?) onChanged,
    required bool enabled,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.grey.shade700 : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value ? Colors.green : Colors.grey.shade600,
          width: value ? 2 : 1,
        ),
      ),
      child: CheckboxListTile(
        title: Row(
          children: [
            Icon(icon, color: value ? Colors.green : Colors.grey.shade400, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: enabled ? Colors.white : Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 28, top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: enabled ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ),
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: Colors.green,
        checkColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildBussolaInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.explore, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Calibrar Bússola',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bussola,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Digite o rumo real (ex: 270)',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              suffixText: '°',
              suffixStyle: const TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.navigation, color: Colors.purple),
              filled: true,
              fillColor: Colors.grey.shade800,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Leitura atual: ${_currentHeading.toInt()}°',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
              Text(
                'Deixe vazio para não calibrar',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
      ),
    );
  }
}