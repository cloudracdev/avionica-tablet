import 'dart:math';
import 'package:flutter/material.dart';
import '../painters/altimetro_painter.dart';

/// Altimeter instrument widget.
///
/// Displays altitude in feet and meters with three pointers (100ft, 1000ft, 10000ft).
/// Includes Kollsman window showing current QNH setting.
/// Tap to adjust QNH (barometric pressure setting).
class AltimetroWidget extends StatefulWidget {
  /// CALIBRATED altitude in meters (already has offset applied)
  final double altitude;

  /// Barometric pressure in Pascals
  final double pressao;

  const AltimetroWidget({
    super.key,
    required this.altitude,
    required this.pressao,
  });

  @override
  State<AltimetroWidget> createState() => _AltimetroWidgetState();
}

class _AltimetroWidgetState extends State<AltimetroWidget> {
  /// QNH adjusted by user (default: 29.92 inHg = 1013.25 hPa)
  double _qnhAjustado = 29.92;

  @override
  Widget build(BuildContext context) {
    // ✅ USA ALTITUDE JÁ CALIBRADA (vem com offset aplicado!)
    double altitudeMetros = widget.altitude;
    
    // Convert to feet
    double altitudeFeet = altitudeMetros * 3.28084;

    return GestureDetector(
      onTap: () => _mostrarAjusteKollsman(context),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          border: Border.all(color: Colors.orange, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'ALTÍMETRO',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Instrument (uses separate Painter)
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: CustomPaint(
                      painter: AltimetroPainter(
                        altitudeFeet: altitudeFeet,
                        altitudeMeters: altitudeMetros,
                        qnhInHg: _qnhAjustado,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Numeric values
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${altitudeFeet.toStringAsFixed(0)} ft | '
                '${altitudeMetros.toStringAsFixed(1)} m',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows Kollsman adjustment dialog.
  void _mostrarAjusteKollsman(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _KollsmanDialog(
        qnhInicial: _qnhAjustado,
        onQnhChanged: (novoQnh) {
          setState(() {
            _qnhAjustado = novoQnh;
          });
        },
      ),
    );
  }
}

/// Dialog for adjusting QNH (Kollsman window).
class _KollsmanDialog extends StatefulWidget {
  final double qnhInicial;
  final Function(double) onQnhChanged;

  const _KollsmanDialog({
    required this.qnhInicial,
    required this.onQnhChanged,
  });

  @override
  State<_KollsmanDialog> createState() => _KollsmanDialogState();
}

class _KollsmanDialogState extends State<_KollsmanDialog> {
  late double _qnh;

  @override
  void initState() {
    super.initState();
    _qnh = widget.qnhInicial;
  }

  void _ajustarQnh(double incremento) {
    setState(() {
      _qnh = (_qnh + incremento).clamp(28.00, 31.00);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.orange, width: 3),
      ),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              '🎛️ AJUSTE KOLLSMAN',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pressão Barométrica',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),

            // QNH Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'QNH: ',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _qnh.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Text(
                    ' inHg',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Adjustment buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BotaoAjuste(
                  icon: Icons.keyboard_double_arrow_down,
                  label: '-0.10',
                  onPressed: () => _ajustarQnh(-0.10),
                  color: Colors.red,
                ),
                _BotaoAjuste(
                  icon: Icons.keyboard_arrow_down,
                  label: '-0.01',
                  onPressed: () => _ajustarQnh(-0.01),
                  color: Colors.orange,
                ),
                _BotaoAjuste(
                  icon: Icons.keyboard_arrow_up,
                  label: '+0.01',
                  onPressed: () => _ajustarQnh(0.01),
                  color: Colors.orange,
                ),
                _BotaoAjuste(
                  icon: Icons.keyboard_double_arrow_up,
                  label: '+0.10',
                  onPressed: () => _ajustarQnh(0.10),
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Range: 28.00 - 31.00 inHg',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Padrão: 29.92 inHg (1013.25 hPa)',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _qnh = 29.92; // Reset to standard
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'PADRÃO',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onQnhChanged(_qnh);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'APLICAR',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Adjustment button widget.
class _BotaoAjuste extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _BotaoAjuste({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 32),
          color: color,
          style: IconButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: color, width: 2),
            ),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}