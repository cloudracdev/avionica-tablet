import 'dart:math';
import 'package:flutter/material.dart';

class BussolaWidget extends StatefulWidget {
  final double heading;

  const BussolaWidget({
    Key? key,
    required this.heading,
  }) : super(key: key);

  @override
  State<BussolaWidget> createState() => _BussolaWidgetState();
}

class _BussolaWidgetState extends State<BussolaWidget> {
  double _displayHeading = 0;
  
  @override
  void initState() {
    super.initState();
    _displayHeading = _normalizeHeading(widget.heading);
  }

  @override
  void didUpdateWidget(BussolaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Calcular menor distância angular para transição suave
    double newHeading = _normalizeHeading(widget.heading);
    double diff = newHeading - _displayHeading;
    
    // Ajustar para pegar caminho mais curto
    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff += 360;
    }
    
    _displayHeading = _normalizeHeading(_displayHeading + diff);
  }

  double _normalizeHeading(double heading) {
    while (heading < 0) heading += 360;
    while (heading >= 360) heading -= 360;
    return heading;
  }

  String _getCardinalDirection(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'N';
    if (degrees >= 22.5 && degrees < 67.5) return 'NE';
    if (degrees >= 67.5 && degrees < 112.5) return 'E';
    if (degrees >= 112.5 && degrees < 157.5) return 'SE';
    if (degrees >= 157.5 && degrees < 202.5) return 'S';
    if (degrees >= 202.5 && degrees < 247.5) return 'SO';
    if (degrees >= 247.5 && degrees < 292.5) return 'O';
    return 'NO';
  }

  @override
  Widget build(BuildContext context) {
    String cardinal = _getCardinalDirection(_displayHeading);
    
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: Colors.purple, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'BÚSSOLA',
            style: TextStyle(
              color: Colors.purple,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Icon(Icons.explore, color: Colors.purple, size: 24),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomPaint(
                    painter: BussolaPainter(heading: _displayHeading),
                    child: Container(),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${_displayHeading.toInt()}° ($cardinal)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BussolaPainter extends CustomPainter {
  final double heading;

  BussolaPainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Fundo
    final bgPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Desenhar disco rotativo com marcações
    _drawCompassRose(canvas, center, radius);

    // Desenhar avião fixo no centro (lubber line)
    _drawAirplane(canvas, center, radius);

    // Borda
    final borderPaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawCompassRose(Canvas canvas, Offset center, double radius) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    
    // Rotacionar disco OPOSTO ao heading (heading aumenta = disco rotaciona anti-horário)
    canvas.rotate(-heading * pi / 180);

    // Desenhar marcações e números
    for (int angle = 0; angle < 360; angle += 10) {
      canvas.save();
      canvas.rotate(angle * pi / 180);

      final isCardinal = angle % 90 == 0;
      final isMajor = angle % 30 == 0;

      // Marcação
      final markPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = isCardinal ? 2.5 : (isMajor ? 1.5 : 1)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final outerRadius = radius * 0.85;
      final innerRadius = isCardinal 
          ? radius * 0.68 
          : (isMajor ? radius * 0.74 : radius * 0.78);

      canvas.drawLine(
        Offset(0, -outerRadius),
        Offset(0, -innerRadius),
        markPaint,
      );

      // Texto (apenas cardinals e múltiplos de 30)
      if (isMajor) {
        String label;
        if (angle == 0) {
          label = 'N';
        } else if (angle == 90) {
          label = 'E';
        } else if (angle == 180) {
          label = 'S';
        } else if (angle == 270) {
          label = 'O';
        } else {
          label = (angle ~/ 10).toString();
        }

        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isCardinal ? 14 : 10,
              fontWeight: isCardinal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        canvas.save();
        canvas.translate(0, -radius * 0.56);
        canvas.rotate(-angle * pi / 180); // Contra-rotacionar texto
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );
        canvas.restore();
      }

      canvas.restore();
    }

    canvas.restore();
  }

  void _drawAirplane(Canvas canvas, Offset center, double radius) {
    final planePaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Linha superior (lubber line) - indicador fixo
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.9),
      Offset(center.dx, center.dy - radius * 0.6),
      Paint()
        ..color = Colors.yellow
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Asas do avião (pequenas, no centro)
    canvas.drawLine(
      Offset(center.dx - radius * 0.15, center.dy),
      Offset(center.dx + radius * 0.15, center.dy),
      planePaint,
    );

    // Fuselagem
    canvas.drawLine(
      Offset(center.dx, center.dy + radius * 0.08),
      Offset(center.dx, center.dy - radius * 0.12),
      planePaint,
    );

    // Nariz (triângulo)
    final nosePath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.12)
      ..lineTo(center.dx - radius * 0.04, center.dy - radius * 0.06)
      ..lineTo(center.dx + radius * 0.04, center.dy - radius * 0.06)
      ..close();
    
    canvas.drawPath(
      nosePath,
      Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(BussolaPainter oldDelegate) {
    return oldDelegate.heading != heading;
  }
}