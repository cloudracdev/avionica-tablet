import 'dart:math';
import 'package:flutter/material.dart';

class CoordenadorWidget extends StatelessWidget {
  final double roll;
  final double turnRate;
  final double accelX;
  final double accelY;

  const CoordenadorWidget({
    Key? key,
    required this.roll,
    this.turnRate = 0,
    this.accelX = 0,
    this.accelY = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: Colors.teal, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'COORDENADOR',
            style: TextStyle(
              color: Colors.teal,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Icon(Icons.sync, color: Colors.teal, size: 24),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomPaint(
                    painter: CoordenadorPainter(
                      roll: roll,
                      turnRate: turnRate,
                      accelX: accelX,
                      accelY: accelY,
                    ),
                    child: Container(),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Roll: ${roll.toInt()}°',
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

class CoordenadorPainter extends CustomPainter {
  final double roll;
  final double turnRate;
  final double accelX;
  final double accelY;

  CoordenadorPainter({
    required this.roll,
    required this.turnRate,
    required this.accelX,
    required this.accelY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Fundo
    final bgPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Borda
    final borderPaint = Paint()
      ..color = Colors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    // AGULHA (Bank Angle) - 30° roll = marca lateral
    double needleAngle = (roll / 30.0).clamp(-1.0, 1.0);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(needleAngle * pi / 6);

    final needlePaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, radius * 0.2),
      Offset(0, -radius * 0.7),
      needlePaint,
    );

    canvas.restore();

    // MARCAS L/R
    final markPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(center.dx - radius * 0.7, center.dy),
      Offset(center.dx - radius * 0.85, center.dy),
      markPaint,
    );

    canvas.drawLine(
      Offset(center.dx + radius * 0.7, center.dy),
      Offset(center.dx + radius * 0.85, center.dy),
      markPaint,
    );

    // BOLINHA (Slip/Skid)
    double rollRad = roll * pi / 180;
    double lateralAccel = accelY * cos(rollRad) + accelX * sin(rollRad);
    double ballOffset = (lateralAccel / 1.0).clamp(-1.0, 1.0) * radius * 0.3;

    // Trilho
    final trackPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;

    final trackRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.5),
        width: radius * 0.8,
        height: radius * 0.15,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(trackRect, trackPaint);

    // Bolinha
    final ballPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx + ballOffset, center.dy + radius * 0.5),
      radius * 0.08,
      ballPaint,
    );

    // Marcas de referência
    final refPaint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(center.dx - radius * 0.15, center.dy + radius * 0.42),
      Offset(center.dx - radius * 0.15, center.dy + radius * 0.58),
      refPaint,
    );

    canvas.drawLine(
      Offset(center.dx + radius * 0.15, center.dy + radius * 0.42),
      Offset(center.dx + radius * 0.15, center.dy + radius * 0.58),
      refPaint,
    );

    // Texto L/R
    _drawText(canvas, 'L', Offset(center.dx - radius * 0.85, center.dy - 20));
    _drawText(canvas, 'R', Offset(center.dx + radius * 0.85, center.dy - 20));
  }

  void _drawText(Canvas canvas, String text, Offset position) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy),
    );
  }

  @override
  bool shouldRepaint(CoordenadorPainter oldDelegate) {
    return oldDelegate.roll != roll || 
           oldDelegate.turnRate != turnRate ||
           oldDelegate.accelX != accelX ||
           oldDelegate.accelY != accelY;
  }
}