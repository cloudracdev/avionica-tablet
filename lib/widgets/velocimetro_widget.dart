import 'dart:math';
import 'package:flutter/material.dart';

class VelocimetroWidget extends StatelessWidget {
  final double velocidade; // em km/h

  const VelocimetroWidget({
    Key? key,
    required this.velocidade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Converter km/h para knots (1 knot = 1.852 km/h)
    double velocidadeKnots = velocidade / 1.852;
    
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'VELOCIDADE',
              style: TextStyle(
                color: Colors.green,
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
                    painter: VelocimetroPainter(
                      velocidadeKnots: velocidadeKnots,
                      velocidadeKmh: velocidade,
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
              '${velocidadeKnots.toStringAsFixed(1)} nós | ${velocidade.toStringAsFixed(1)} km/h',
              style: const TextStyle(
                color: Colors.grey,
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

class VelocimetroPainter extends CustomPainter {
  final double velocidadeKnots;
  final double velocidadeKmh;

  VelocimetroPainter({
    required this.velocidadeKnots,
    required this.velocidadeKmh,
  });

  // 🎯 CONVERSÃO NÓS → ÂNGULO
  double knotsToAngle(double knots) {
    if (knots <= 0) {
      return 0;
    } else if (knots <= 40) {
      return knots * 0.4;
    } else if (knots <= 240) {
      return 16 + (knots - 40) * 1.64;
    } else {
      return 344;
    }
  }

  // 🔄 CONVERSÃO PARA POSICIONAMENTO (números)
  double angleToRadiansForPosition(double degrees) {
    return (degrees - 90) * pi / 180;
  }

  // 🔄 CONVERSÃO PARA ROTAÇÃO (ponteiro e linhas)
  double angleToRadiansForRotation(double degrees) {
    return degrees * pi / 180;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Fundo preto fosco
    final bgPaint = Paint()..color = const Color(0xFF0A0A0A);
    canvas.drawCircle(center, radius * 0.90, bgPaint);

    // Desenhar arcos coloridos e linha branca (PRIMEIRO - por baixo)
    _drawColoredArcs(canvas, center, radius);
    _drawWhiteLine(canvas, center, radius);

    // Desenhar linhas de marcação (POR CIMA das cores)
    _drawScaleMarks(canvas, center, radius);
    
    // Desenhar números
    _drawNumbers(canvas, center, radius);
    
    // Desenhar ponteiro
    _drawNeedle(canvas, center, radius);

    // Borda externa verde
    final borderPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawColoredArcs(Canvas canvas, Offset center, double radius) {
    // Arco VERDE: 60 → 150 nós
    // MESMA posição das linhas (radius * 0.94)
    double greenStart = knotsToAngle(60);
    double greenEnd = knotsToAngle(150);
    double greenStartRad = angleToRadiansForPosition(greenStart);
    double greenSweep = (greenEnd - greenStart) * pi / 180;

    final greenPaint = Paint()
      ..color = Colors.green.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.12  // Largura para cobrir área das linhas
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.94),
      greenStartRad,
      greenSweep,
      false,
      greenPaint,
    );

    // Arco AMARELO: 150 → 200 nós
    double yellowStart = knotsToAngle(150);
    double yellowEnd = knotsToAngle(200);
    double yellowStartRad = angleToRadiansForPosition(yellowStart);
    double yellowSweep = (yellowEnd - yellowStart) * pi / 180;

    final yellowPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.12
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.94),
      yellowStartRad,
      yellowSweep,
      false,
      yellowPaint,
    );

    // Arco VERMELHO: 200 → 220 nós
    double redStart = knotsToAngle(200);
    double redEnd = knotsToAngle(220);
    double redStartRad = angleToRadiansForPosition(redStart);
    double redSweep = (redEnd - redStart) * pi / 180;

    final redPaint = Paint()
      ..color = Colors.red.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.12
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.94),
      redStartRad,
      redSweep,
      false,
      redPaint,
    );
  }

  void _drawWhiteLine(Canvas canvas, Offset center, double radius) {
    // Linha branca interna grossa: 50 → 90 nós
    // Toca borda interna das cores e linhas (88%)
    double lineStart = knotsToAngle(50);
    double lineEnd = knotsToAngle(90);
    double lineStartRad = angleToRadiansForPosition(lineStart);
    double lineSweep = (lineEnd - lineStart) * pi / 180;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.88),
      lineStartRad,
      lineSweep,
      false,
      whitePaint,
    );
  }

  void _drawScaleMarks(Canvas canvas, Offset center, double radius) {
    // LINHAS GRANDES: apenas nos números (40, 60, 80...240)
    final mainMarks = [40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240];
    
    for (final knots in mainMarks) {
      double angle = knotsToAngle(knots.toDouble());
      double radian = angleToRadiansForRotation(angle);
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(radian);

      final markPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(0, -radius * 0.88),
        Offset(0, -radius * 1.00),
        markPaint,
      );

      canvas.restore();
    }
    
    // LINHAS PEQUENAS: apenas entre os números (50, 70, 90...230)
    final smallMarks = [50, 70, 90, 110, 130, 150, 170, 190, 210, 230];
    
    for (final knots in smallMarks) {
      double angle = knotsToAngle(knots.toDouble());
      double radian = angleToRadiansForRotation(angle);
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(radian);

      final markPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(0, -radius * 0.92),
        Offset(0, -radius * 1.00),
        markPaint,
      );

      canvas.restore();
    }
  }

  void _drawNumbers(Canvas canvas, Offset center, double radius) {
    // Números: 40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240
    final numbers = [40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240];

    for (final knots in numbers) {
      double angle = knotsToAngle(knots.toDouble());
      double radian = angleToRadiansForPosition(angle);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: knots.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      double textRadius = radius * 0.70;
      double x = center.dx + textRadius * cos(radian);
      double y = center.dy + textRadius * sin(radian);

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    double clampedKnots = velocidadeKnots.clamp(0.0, 240.0);
    double angle = knotsToAngle(clampedKnots);
    double radian = angleToRadiansForRotation(angle);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(radian);

    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, radius * 0.10),
      Offset(0, -radius * 0.85),
      needlePaint,
    );

    canvas.restore();

    // Pivot central
    canvas.drawCircle(center, radius * 0.05, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius * 0.05, Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(VelocimetroPainter oldDelegate) {
    return oldDelegate.velocidadeKnots != velocidadeKnots ||
           oldDelegate.velocidadeKmh != velocidadeKmh;
  }
}