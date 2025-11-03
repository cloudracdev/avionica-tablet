import 'package:flutter/material.dart';
import 'dart:math' as math;

class VariometroWidget extends StatelessWidget {
  final double vario; // em m/s

  const VariometroWidget({
    Key? key,
    required this.vario,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Converter m/s para ft/min
    // 1 m/s = 196.85 ft/min
    double varioFtPerMin = vario * 196.85;
    double varioScaled = varioFtPerMin / 1000.0; // Valor na escala -2 a +2
    
    // Cor da borda baseada no valor
    Color borderColor = vario > 0 ? Colors.green : (vario < 0 ? Colors.red : Colors.cyan);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Título
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'VARIÔMETRO',
              style: TextStyle(
                color: borderColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Instrumento principal
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: CustomPaint(
                    painter: VariometroPainter(
                      varioScaled: varioScaled,
                      varioMs: vario,
                    ),
                    child: Container(),
                  ),
                ),
              ),
            ),
          ),
          
          // Valores em m/s e ft/min embaixo
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${vario >= 0 ? '+' : ''}${vario.toStringAsFixed(1)} m/s | ${varioFtPerMin >= 0 ? '+' : ''}${varioFtPerMin.toStringAsFixed(0)} ft/min',
              style: TextStyle(
                color: vario >= 0 ? Colors.green : Colors.red,
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

class VariometroPainter extends CustomPainter {
  final double varioScaled;
  final double varioMs;

  VariometroPainter({
    required this.varioScaled,
    required this.varioMs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Fundo preto fosco (igual aos outros instrumentos)
    final bgPaint = Paint()..color = const Color(0xFF0A0A0A);
    canvas.drawCircle(center, radius * 0.90, bgPaint);

    // Desenhar escala e números
    _drawScale(canvas, center, radius);
    
    // Textos centrais
    _drawCenterTexts(canvas, center, radius);
    
    // Textos "up" e "dn"
    _drawUpDownTexts(canvas, center, radius);
    
    // Desenhar ponteiro
    _drawNeedle(canvas, center, radius);
    
    // Hub central
    _drawCenterHub(canvas, center, radius);

    // Borda externa com cor dinâmica (verde/vermelho/cyan)
    Color borderColor = varioMs > 0 ? Colors.green : (varioMs < 0 ? Colors.red : Colors.cyan);
    
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawScale(Canvas canvas, Offset center, double radius) {
    // MARCAÇÕES E NÚMEROS baseados na foto real
    // Zero na posição 9h (180°)
    // Escala: 0 → .5 → 1 → 1.5 → 2 (metade superior = subida)
    //         0 → .5 → 1 → 1.5 → 2 (metade inferior = descida)
    
    final positions = [
      // Subida (de 9h sentido horário até 3h pelo topo)
      {'value': '0', 'angle': 180.0, 'isMajor': true},      // 9h (esquerda)
      {'value': '', 'angle': 202.5, 'isMajor': false},      
      {'value': '.5', 'angle': 225.0, 'isMajor': false},    // 10:30h
      {'value': '', 'angle': 247.5, 'isMajor': false},
      {'value': '1', 'angle': 270.0, 'isMajor': true},      // 12h (topo)
      {'value': '', 'angle': 292.5, 'isMajor': false},
      {'value': '1.5', 'angle': 315.0, 'isMajor': false},   // 1:30h
      {'value': '', 'angle': 337.5, 'isMajor': false},
      {'value': '2', 'angle': 0.0, 'isMajor': true},        // 3h (direita)
      
      // Descida (de 3h sentido horário até 9h por baixo)
      {'value': '', 'angle': 22.5, 'isMajor': false},
      {'value': '1.5', 'angle': 45.0, 'isMajor': false},    // 4:30h
      {'value': '', 'angle': 67.5, 'isMajor': false},
      {'value': '1', 'angle': 90.0, 'isMajor': true},       // 6h (embaixo)
      {'value': '', 'angle': 112.5, 'isMajor': false},
      {'value': '.5', 'angle': 135.0, 'isMajor': false},    // 7:30h
      {'value': '', 'angle': 157.5, 'isMajor': false},
    ];

    for (var pos in positions) {
      double angleDeg = pos['angle'] as double;
      double angleRad = angleDeg * math.pi / 180;
      bool isMajor = pos['isMajor'] as bool;
      String value = pos['value'] as String;

      // Desenhar linha de marcação
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angleRad);

      final markPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = isMajor ? 2.5 : 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      double innerRadius = isMajor ? radius * 0.85 : radius * 0.90;
      canvas.drawLine(
        Offset(0, -innerRadius),
        Offset(0, -radius * 0.98),
        markPaint,
      );

      canvas.restore();

      // Desenhar número (apenas para marcações maiores com valor)
      if (value.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: value,
            style: TextStyle(
              color: Colors.white,
              fontSize: radius * 0.12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // Posicionamento correto: angleRad já está correto, não precisa subtrair pi/2
        double textRadius = radius * 0.70;
        double x = center.dx + textRadius * math.cos(angleRad);
        double y = center.dy + textRadius * math.sin(angleRad);

        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    }
  }

  void _drawCenterTexts(Canvas canvas, Offset center, double radius) {
    // "1000 ft. per min"
    _drawText(
      canvas,
      '1000 ft.',
      Offset(center.dx, center.dy - radius * 0.05),
      Colors.white,
      radius * 0.08,
      FontWeight.normal,
    );
    _drawText(
      canvas,
      'per min',
      Offset(center.dx, center.dy + radius * 0.08),
      Colors.white,
      radius * 0.08,
      FontWeight.normal,
    );
  }

  void _drawUpDownTexts(Canvas canvas, Offset center, double radius) {
    // Desenhar setinha para cima e texto "up"
    final arrowUpPath = Path()
      ..moveTo(center.dx - radius * 0.68, center.dy - radius * 0.18)
      ..lineTo(center.dx - radius * 0.68, center.dy - radius * 0.10)
      ..moveTo(center.dx - radius * 0.68, center.dy - radius * 0.18)
      ..lineTo(center.dx - radius * 0.72, center.dy - radius * 0.14)
      ..moveTo(center.dx - radius * 0.68, center.dy - radius * 0.18)
      ..lineTo(center.dx - radius * 0.64, center.dy - radius * 0.14);

    canvas.drawPath(
      arrowUpPath,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    _drawText(
      canvas,
      'up',
      Offset(center.dx - radius * 0.55, center.dy - radius * 0.14),
      Colors.white,
      radius * 0.08,
      FontWeight.normal,
    );

    // Desenhar setinha para baixo e texto "dn"
    final arrowDownPath = Path()
      ..moveTo(center.dx - radius * 0.68, center.dy + radius * 0.18)
      ..lineTo(center.dx - radius * 0.68, center.dy + radius * 0.10)
      ..moveTo(center.dx - radius * 0.68, center.dy + radius * 0.18)
      ..lineTo(center.dx - radius * 0.72, center.dy + radius * 0.14)
      ..moveTo(center.dx - radius * 0.68, center.dy + radius * 0.18)
      ..lineTo(center.dx - radius * 0.64, center.dy + radius * 0.14);

    canvas.drawPath(
      arrowDownPath,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    _drawText(
      canvas,
      'dn',
      Offset(center.dx - radius * 0.55, center.dy + radius * 0.14),
      Colors.white,
      radius * 0.08,
      FontWeight.normal,
    );
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    // Converter valor para ângulo
    // A linha desenhada naturalmente aponta para CIMA (270° no canvas)
    // Precisamos subtrair 90° para corrigir isso
    
    double clampedValue = varioScaled.clamp(-2.0, 2.0);
    double needleAngle;
    
    if (clampedValue >= 0) {
      // Subida: SENTIDO HORÁRIO de 180° até 360°/0°
      // Mapeamento: 0 → 180°, +2 → 360° (= 0°) passando por 270° (topo)
      needleAngle = 180 + (clampedValue * 90); // 180° a 360°
    } else {
      // Descida: ANTI-HORÁRIO de 180° até 0°
      // Mapeamento: 0 → 180°, -2 → 0° passando por 90° (embaixo)
      needleAngle = 180 - (clampedValue.abs() * 90); // 180° a 0°
    }
    
    // CORREÇÃO: subtrair 270° porque a linha aponta para CIMA e queremos ESQUERDA no zero
    double needleRad = (needleAngle - 270) * math.pi / 180;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(needleRad);

    // Desenhar ponteiro branco
    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, radius * 0.08),
      Offset(0, -radius * 0.70),
      needlePaint,
    );

    // Ponta amarela
    canvas.drawCircle(
      Offset(0, -radius * 0.70),
      radius * 0.03,
      Paint()..color = Colors.yellow..style = PaintingStyle.fill,
    );

    canvas.restore();
  }

  void _drawCenterHub(Canvas canvas, Offset center, double radius) {
    // Hub central branco
    canvas.drawCircle(
      center,
      radius * 0.05,
      Paint()..color = Colors.white..style = PaintingStyle.fill,
    );
    
    // Borda preta do hub
    canvas.drawCircle(
      center,
      radius * 0.05,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawText(Canvas canvas, String text, Offset position, Color color, double fontSize, FontWeight weight) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(VariometroPainter oldDelegate) {
    return oldDelegate.varioScaled != varioScaled || 
           oldDelegate.varioMs != varioMs;
  }
}