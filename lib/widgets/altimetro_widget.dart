import 'dart:math';
import 'package:flutter/material.dart';

class AltimetroWidget extends StatelessWidget {
  final double altitude; // em metros

  const AltimetroWidget({
    Key? key,
    required this.altitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Converter metros para pés
    double altitudeFeet = altitude * 3.28084;
    
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: CustomPaint(
                    painter: AltimetroPainter(
                      altitudeFeet: altitudeFeet,
                      altitudeMeters: altitude,
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
              '${altitudeFeet.toStringAsFixed(0)} ft | ${altitude.toStringAsFixed(1)} m',
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

class AltimetroPainter extends CustomPainter {
  final double altitudeFeet;
  final double altitudeMeters;

  AltimetroPainter({
    required this.altitudeFeet,
    required this.altitudeMeters,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Fundo preto fosco
    final bgPaint = Paint()..color = const Color(0xFF0A0A0A);
    canvas.drawCircle(center, radius * 0.90, bgPaint);

    // Desenhar escala (números e marcações)
    _drawScale(canvas, center, radius);
    
    // Desenhar os 3 ponteiros (ordem: 10k, 1k, 100 - do menor para o maior)
    _drawPointer10000(canvas, center, radius);
    _drawPointer1000(canvas, center, radius);
    _drawPointer100(canvas, center, radius);
    
    // Hub central
    _drawCenterHub(canvas, center, radius);

    // Borda externa laranja
    final borderPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawScale(Canvas canvas, Offset center, double radius) {
    // Desenhar números 0-9 e marcações
    for (int i = 0; i < 10; i++) {
      double angle = (i * 36.0 - 90) * pi / 180; // -90 para começar no topo
      
      // Número
      final textPainter = TextPainter(
        text: TextSpan(
          text: i.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      double textRadius = radius * 0.70;
      double x = center.dx + textRadius * cos(angle);
      double y = center.dy + textRadius * sin(angle);

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );

      // Linha principal do número (mais grossa)
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle + pi / 2); // Ajustar para ficar perpendicular

      final mainMarkPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(0, -radius * 0.85),
        Offset(0, -radius * 1.00),
        mainMarkPaint,
      );

      canvas.restore();

      // 4 linhas pequenas entre cada número (exceto após o 9)
      if (i < 9) {
        for (int j = 1; j <= 4; j++) {
          double smallAngle = ((i * 36.0) + (j * 7.2) - 90) * pi / 180;
          
          canvas.save();
          canvas.translate(center.dx, center.dy);
          canvas.rotate(smallAngle + pi / 2);

          final smallMarkPaint = Paint()
            ..color = Colors.white
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

          canvas.drawLine(
            Offset(0, -radius * 0.92),
            Offset(0, -radius * 1.00),
            smallMarkPaint,
          );

          canvas.restore();
        }
      }
    }
  }

  void _drawPointer100(Canvas canvas, Offset center, double radius) {
    // Ponteiro de 100 pés (médio/fino)
    // 1 volta completa = 1000 pés
    double feet100 = altitudeFeet % 1000;
    double angle = (feet100 / 1000) * 360;
    double radian = angle * pi / 180;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(radian);

    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Ponteiro médio: pequena cauda até ponta
    canvas.drawLine(
      Offset(0, radius * 0.08),
      Offset(0, -radius * 0.65),
      needlePaint,
    );

    canvas.restore();
  }

  void _drawPointer1000(Canvas canvas, Offset center, double radius) {
    // Ponteiro de 1000 pés (curto/grosso)
    // 1 volta completa = 10.000 pés
    double feet1000 = (altitudeFeet % 10000) / 1000;
    double angle = (feet1000 / 10) * 360;
    double radian = angle * pi / 180;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(radian);

    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Ponteiro curto e grosso
    canvas.drawLine(
      Offset(0, radius * 0.08),
      Offset(0, -radius * 0.55),
      needlePaint,
    );

    canvas.restore();
  }

  void _drawPointer10000(Canvas canvas, Offset center, double radius) {
    // Ponteiro de 10.000 pés (longo/fino)
    // 1 volta completa = 100.000 pés
    double feet10000 = altitudeFeet / 10000;
    double angle = (feet10000 / 10) * 360;
    double radian = angle * pi / 180;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(radian);

    final needlePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Ponteiro longo e fino
    canvas.drawLine(
      Offset(0, radius * 0.08),
      Offset(0, -radius * 0.75),
      needlePaint,
    );
    
    // Ponta triangular
    final trianglePath = Path()
      ..moveTo(0, -radius * 0.75)
      ..lineTo(-radius * 0.02, -radius * 0.70)
      ..lineTo(radius * 0.02, -radius * 0.70)
      ..close();
    
    canvas.drawPath(
      trianglePath,
      Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..style = PaintingStyle.fill,
    );

    canvas.restore();
  }

  void _drawCenterHub(Canvas canvas, Offset center, double radius) {
    // Hub central branco
    canvas.drawCircle(center, radius * 0.06, Paint()..color = Colors.white);
    
    // Borda preta do hub
    canvas.drawCircle(
      center,
      radius * 0.06,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(AltimetroPainter oldDelegate) {
    return oldDelegate.altitudeFeet != altitudeFeet ||
           oldDelegate.altitudeMeters != altitudeMeters;
  }
}