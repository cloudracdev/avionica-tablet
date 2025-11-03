import 'dart:math';
import 'package:flutter/material.dart';

class AltimetroWidget extends StatefulWidget {
  final double altitude; // em metros
  final double pressao; // em Pascal (Pa)

  const AltimetroWidget({
    Key? key,
    required this.altitude,
    required this.pressao,
  }) : super(key: key);

  @override
  State<AltimetroWidget> createState() => _AltimetroWidgetState();
}

class _AltimetroWidgetState extends State<AltimetroWidget> {
  // QNH ajustado pelo usuário (padrão: 29.92 inHg = 1013.25 hPa)
  double _qnhAjustado = 29.92;
  
  @override
  Widget build(BuildContext context) {
    // 🔧 CÁLCULO CORRETO DE ALTITUDE COM FÓRMULA BAROMÉTRICA
    
    // Converter QNH de inHg para Pa
    // 1 inHg = 3386.39 Pa
    double qnhPa = _qnhAjustado * 3386.39;
    
    // Fórmula barométrica padrão da aviação:
    // h = 44330 × (1 - (P/P0)^0.1903)
    // Onde:
    //   h = altitude em metros
    //   P = pressão medida (Pa)
    //   P0 = pressão de referência QNH (Pa)
    double pressaoPa = widget.pressao;
    double altitudeAjustada = 44330.0 * (1.0 - pow(pressaoPa / qnhPa, 0.1903));
    
    // Converter para pés
    double altitudeFeet = altitudeAjustada * 3.28084;
    
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
                        altitudeMeters: altitudeAjustada,
                        qnhInHg: _qnhAjustado,
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
                '${altitudeFeet.toStringAsFixed(0)} ft | ${altitudeAjustada.toStringAsFixed(1)} m',
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

class AltimetroPainter extends CustomPainter {
  final double altitudeFeet;
  final double altitudeMeters;
  final double qnhInHg; // ✨ NOVO

  AltimetroPainter({
    required this.altitudeFeet,
    required this.altitudeMeters,
    required this.qnhInHg, // ✨ NOVO
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
    
    // ✨ NOVO: Desenhar janela Kollsman
    _drawKollsmanWindow(canvas, center, radius);
    
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

  // ✨ NOVA FUNÇÃO: Desenhar janela Kollsman
  void _drawKollsmanWindow(Canvas canvas, Offset center, double radius) {
    // 🔧 JANELA AINDA MAIS ALTA E MINIMALISTA
    final windowWidth = radius * 0.78;
    final windowHeight = radius * 0.28;
    final windowTop = center.dy + radius * 0.18; // Era 0.28 → AGORA 0.18 (MUITO MAIS ALTO)
    final windowLeft = center.dx - windowWidth / 2;
    
    final windowRect = Rect.fromLTWH(
      windowLeft,
      windowTop,
      windowWidth,
      windowHeight,
    );

    // 🎨 FUNDO IGUAL AO ALTÍMETRO - preto fosco
    canvas.drawRRect(
      RRect.fromRectAndRadius(windowRect, Radius.circular(radius * 0.02)),
      Paint()..color = const Color(0xFF0A0A0A), // Mesmo fundo do altímetro
    );

    // 🎨 BORDA BRANCA
    canvas.drawRRect(
      RRect.fromRectAndRadius(windowRect, Radius.circular(radius * 0.02)),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Formato do valor QNH: sem ponto decimal
    String qnhValue = (qnhInHg * 100).toStringAsFixed(0);
    
    // 🎨 COR DE TEXTO BRANCA
    const textColor = Colors.white;
    
    // 1. Texto ESQUERDA: "QNH"
    final qnhLabelPainter = TextPainter(
      text: TextSpan(
        text: 'QNH',
        style: TextStyle(
          color: textColor,
          fontSize: radius * 0.070,
          fontWeight: FontWeight.w600, // Menos bold
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    qnhLabelPainter.layout();
    qnhLabelPainter.paint(
      canvas,
      Offset(
        windowLeft + radius * 0.05,
        windowTop + windowHeight / 2 - qnhLabelPainter.height / 2,
      ),
    );

    // 2. Texto CENTRAL: Valor QNH
    final valuePainter = TextPainter(
      text: TextSpan(
        text: qnhValue,
        style: TextStyle(
          color: textColor,
          fontSize: radius * 0.115,
          fontWeight: FontWeight.w700, // Menos bold
          fontFamily: 'monospace',
          letterSpacing: 2.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    valuePainter.layout();
    valuePainter.paint(
      canvas,
      Offset(
        center.dx - valuePainter.width / 2,
        windowTop + windowHeight / 2 - valuePainter.height / 2,
      ),
    );

    // 3. Texto DIREITA SUPERIOR: "ft"
    final ftLabelPainter = TextPainter(
      text: TextSpan(
        text: 'ft',
        style: TextStyle(
          color: textColor,
          fontSize: radius * 0.065,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    ftLabelPainter.layout();
    ftLabelPainter.paint(
      canvas,
      Offset(
        windowLeft + windowWidth - ftLabelPainter.width - radius * 0.05,
        windowTop + radius * 0.030,
      ),
    );

    // 4. Texto DIREITA: "in" e "Hg"
    final inPainter = TextPainter(
      text: TextSpan(
        text: 'in',
        style: TextStyle(
          color: textColor,
          fontSize: radius * 0.058,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    inPainter.layout();
    
    final hgPainter = TextPainter(
      text: TextSpan(
        text: 'Hg',
        style: TextStyle(
          color: textColor,
          fontSize: radius * 0.058,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    hgPainter.layout();
    
    // Posicionar "in" e "Hg" bem separados
    double rightX = windowLeft + windowWidth - max(inPainter.width, hgPainter.width) - radius * 0.05;
    
    inPainter.paint(
      canvas,
      Offset(
        rightX + (max(inPainter.width, hgPainter.width) - inPainter.width) / 2,
        windowTop + windowHeight / 2 - inPainter.height / 2 + radius * 0.015,
      ),
    );
    
    hgPainter.paint(
      canvas,
      Offset(
        rightX + (max(inPainter.width, hgPainter.width) - hgPainter.width) / 2,
        windowTop + windowHeight - hgPainter.height - radius * 0.025,
      ),
    );
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
           oldDelegate.altitudeMeters != altitudeMeters ||
           oldDelegate.qnhInHg != qnhInHg; // ✨ NOVO
  }
}

// 🎛️ DIALOG PARA AJUSTAR QNH (BOTÃO KOLLSMAN)
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
            // Título
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
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            
            // Display QNH
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
            
            // Botões de ajuste (simulando botão giratório)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Diminuir GRANDE
                _BotaoAjuste(
                  icon: Icons.keyboard_double_arrow_down,
                  label: '-0.10',
                  onPressed: () => _ajustarQnh(-0.10),
                  color: Colors.red,
                ),
                
                // Diminuir pequeno
                _BotaoAjuste(
                  icon: Icons.keyboard_arrow_down,
                  label: '-0.01',
                  onPressed: () => _ajustarQnh(-0.01),
                  color: Colors.orange,
                ),
                
                // Aumentar pequeno
                _BotaoAjuste(
                  icon: Icons.keyboard_arrow_up,
                  label: '+0.01',
                  onPressed: () => _ajustarQnh(0.01),
                  color: Colors.orange,
                ),
                
                // Aumentar GRANDE
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
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Padrão: 29.92 inHg (1013.25 hPa)',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _qnh = 29.92; // Reset para padrão
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

// Botão de ajuste
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