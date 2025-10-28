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
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'COORDENADOR',
              style: TextStyle(
                color: Colors.teal,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(4),
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
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Roll: ${roll.toInt()}°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
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

    // LINHAS DE REFERÊNCIA (horizonte e ângulos)
    final horizonPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Linha horizontal central (0°/180°)
    canvas.drawLine(
      Offset(center.dx - radius * 0.6, center.dy),
      Offset(center.dx + radius * 0.6, center.dy),
      horizonPaint,
    );

    // Linhas diagonais de referência (~30° e ~330°)
    final double angle30 = 30 * pi / 180;
    canvas.drawLine(
      Offset(center.dx - radius * 0.5 * cos(angle30), center.dy - radius * 0.5 * sin(angle30)),
      Offset(center.dx - radius * 0.6 * cos(angle30), center.dy - radius * 0.6 * sin(angle30)),
      horizonPaint,
    );
    
    canvas.drawLine(
      Offset(center.dx + radius * 0.5 * cos(angle30), center.dy - radius * 0.5 * sin(angle30)),
      Offset(center.dx + radius * 0.6 * cos(angle30), center.dy - radius * 0.6 * sin(angle30)),
      horizonPaint,
    );

    // MARCAS L/R (Standard Rate Turn - verticais nas laterais)
    final markPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Marca L (esquerda)
    canvas.drawLine(
      Offset(center.dx - radius * 0.65, center.dy - radius * 0.08),
      Offset(center.dx - radius * 0.65, center.dy + radius * 0.08),
      markPaint,
    );

    // Marca R (direita)
    canvas.drawLine(
      Offset(center.dx + radius * 0.65, center.dy - radius * 0.08),
      Offset(center.dx + radius * 0.65, center.dy + radius * 0.08),
      markPaint,
    );

    // SILHUETA DO AVIÃO (vista de trás)
    _drawAirplaneSilhouette(canvas, center, radius);

    // INCLINÔMETRO (Ball) - parte inferior
    _drawInclinometer(canvas, center, radius);

    // Texto L/R (próximo da borda, mais abaixo)
    _drawText(canvas, 'L', Offset(center.dx - radius * 0.78, center.dy + radius * 0.12));
    _drawText(canvas, 'R', Offset(center.dx + radius * 0.78, center.dy + radius * 0.12));
  }

  void _drawAirplaneSilhouette(Canvas canvas, Offset center, double radius) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    
    // Rotacionar de acordo com o roll (SEM sinal negativo para sincronizar com horizonte)
    canvas.rotate(roll * pi / 180);

    final planePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Dimensões do avião
    double wingspan = radius * 0.5;
    double fuselageWidth = radius * 0.06;
    double fuselageHeight = radius * 0.18;
    double tailWidth = radius * 0.18;

    // ASAS (linha horizontal principal - bem visível)
    canvas.drawLine(
      Offset(-wingspan, 0),
      Offset(wingspan, 0),
      planePaint,
    );

    // FUSELAGEM (linha vertical central)
    canvas.drawLine(
      Offset(0, fuselageHeight / 2),
      Offset(0, -fuselageHeight),
      planePaint,
    );

    // ESTABILIZADOR HORIZONTAL (cauda em T)
    canvas.drawLine(
      Offset(-tailWidth / 2, -fuselageHeight),
      Offset(tailWidth / 2, -fuselageHeight),
      planePaint,
    );

    // CENTRO (ponto de referência)
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, 0), radius * 0.04, centerPaint);

    canvas.restore();
  }

  void _drawInclinometer(Canvas canvas, Offset center, double radius) {
    // Calcular deslocamento lateral da bolinha
    double rollRad = roll * pi / 180;
    double lateralAccel = accelY * cos(rollRad) + accelX * sin(rollRad);
    double ballOffset = (lateralAccel / 1.0).clamp(-1.0, 1.0) * radius * 0.3;

    // Trilho (tubo curvo)
    final trackPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;

    final trackRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.55),
        width: radius * 0.8,
        height: radius * 0.15,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(trackRect, trackPaint);

    // Bolinha preta
    final ballPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx + ballOffset, center.dy + radius * 0.55),
      radius * 0.08,
      ballPaint,
    );

    // Marcas de referência (limites de coordenação)
    final refPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(center.dx - radius * 0.15, center.dy + radius * 0.47),
      Offset(center.dx - radius * 0.15, center.dy + radius * 0.63),
      refPaint,
    );

    canvas.drawLine(
      Offset(center.dx + radius * 0.15, center.dy + radius * 0.47),
      Offset(center.dx + radius * 0.15, center.dy + radius * 0.63),
      refPaint,
    );
  }

  void _drawText(Canvas canvas, String text, Offset position) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
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