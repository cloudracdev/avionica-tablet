import 'dart:math';
import 'package:flutter/material.dart';

class ArtificialHorizon extends StatelessWidget {
  final double pitch;  // -90 a +90 graus
  final double roll;   // 0 a 360 graus

  const ArtificialHorizon({
    Key? key,
    required this.pitch,
    required this.roll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Título
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'HORIZONTE ARTIFICIAL',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Instrumento (CustomPaint)
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: CustomPaint(
                    painter: HorizonPainter(pitch: pitch, roll: roll),
                    child: Container(),
                  ),
                ),
              ),
            ),
          ),

          // Valores numéricos
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'P:${pitch.toInt()}° R:${roll.toInt()}°',
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

class HorizonPainter extends CustomPainter {
  final double pitch;
  final double roll;

  HorizonPainter({required this.pitch, required this.roll});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Clip circular (borda redonda do instrumento)
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    // Salvar estado do canvas
    canvas.save();

    // Mover origem para o centro
    canvas.translate(center.dx, center.dy);

    // Rotacionar com roll (converter para radianos)
    canvas.rotate(-roll * pi / 180);

    // Deslocar verticalmente com pitch (1 grau = 3 pixels)
    double pitchOffset = pitch * 3;
    canvas.translate(0, pitchOffset);

    // Desenhar CÉU (azul)
    final skyPaint = Paint()..color = const Color(0xFF0077BE);
    canvas.drawRect(
      Rect.fromLTWH(-radius * 2, -radius * 2, radius * 4, radius * 2),
      skyPaint,
    );

    // Desenhar TERRA (marrom)
    final groundPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawRect(
      Rect.fromLTWH(-radius * 2, 0, radius * 4, radius * 2),
      groundPaint,
    );

    // Desenhar LINHA DO HORIZONTE (branca grossa)
    final horizonPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(-radius * 1.5, 0),
      Offset(radius * 1.5, 0),
      horizonPaint,
    );

    // Desenhar ESCALAS DE PITCH
    final scalePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Linhas de pitch a cada 10 graus
    for (int angle = -90; angle <= 90; angle += 10) {
      if (angle == 0) continue; // Pular linha do horizonte

      double y = -angle * 3.0; // Negativo porque Y cresce para baixo
      double lineWidth = (angle % 20 == 0) ? 40.0 : 25.0; // Linhas maiores a cada 20°

      // Desenhar linha
      canvas.drawLine(
        Offset(-lineWidth, y),
        Offset(lineWidth, y),
        scalePaint,
      );

      // Desenhar número (apenas múltiplos de 10)
      if (angle.abs() >= 10) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: angle.abs().toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // Números dos dois lados
        textPainter.paint(canvas, Offset(-lineWidth - 20, y - 6));
        textPainter.paint(canvas, Offset(lineWidth + 8, y - 6));
      }
    }

    // Restaurar canvas
    canvas.restore();

    // Desenhar AVIÃOZINHO FIXO no centro (não rotaciona)
    final planePaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Asas do avião (horizontal)
    canvas.drawLine(
      Offset(center.dx - 50, center.dy),
      Offset(center.dx - 15, center.dy),
      planePaint,
    );
    canvas.drawLine(
      Offset(center.dx + 15, center.dy),
      Offset(center.dx + 50, center.dy),
      planePaint,
    );

    // Centro do avião (círculo)
    canvas.drawCircle(center, 5, Paint()..color = Colors.yellow);

    // Nariz do avião (triângulo pequeno)
    final nosePath = Path()
      ..moveTo(center.dx, center.dy - 10)
      ..lineTo(center.dx - 4, center.dy - 2)
      ..lineTo(center.dx + 4, center.dy - 2)
      ..close();
    canvas.drawPath(nosePath, Paint()..color = Colors.yellow);

    // Desenhar BORDA CIRCULAR externa
    final borderPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, borderPaint);

    // Desenhar MARCAS DE ROLL no topo
    _drawRollMarks(canvas, center, radius);
  }

  void _drawRollMarks(Canvas canvas, Offset center, double radius) {
    final markPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Marcas de roll: 0°, 10°, 20°, 30°, 45°, 60°
    final angles = [0, 10, 20, 30, 45, 60];

    for (final angle in angles) {
      for (final side in [-1, 1]) {
        final actualAngle = angle * side;
        final radian = (actualAngle - 90) * pi / 180; // -90 para começar no topo

        final outerX = center.dx + radius * 0.95 * cos(radian);
        final outerY = center.dy + radius * 0.95 * sin(radian);
        final innerX = center.dx + radius * 0.85 * cos(radian);
        final innerY = center.dy + radius * 0.85 * sin(radian);

        // Marca maior para 0°, 30°, 60°
        final length = (angle == 0 || angle == 30 || angle == 60) ? 0.85 : 0.90;
        final finalInnerX = center.dx + radius * length * cos(radian);
        final finalInnerY = center.dy + radius * length * sin(radian);

        canvas.drawLine(
          Offset(outerX, outerY),
          Offset(finalInnerX, finalInnerY),
          markPaint,
        );
      }
    }

    // Triângulo indicador no topo (marca atual de roll)
    final trianglePath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.80)
      ..lineTo(center.dx - 6, center.dy - radius * 0.92)
      ..lineTo(center.dx + 6, center.dy - radius * 0.92)
      ..close();

    canvas.drawPath(trianglePath, Paint()..color = Colors.yellow);
  }

  @override
  bool shouldRepaint(HorizonPainter oldDelegate) {
    return oldDelegate.pitch != pitch || oldDelegate.roll != roll;
  }
}