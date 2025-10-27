import 'package:flutter/material.dart';

class BaseInstrumento extends StatelessWidget {
  final String titulo;
  final String valor;
  final String unidade;
  final Color cor;
  final IconData icone;
  final double fontSize;

  const BaseInstrumento({
    Key? key,
    required this.titulo,
    required this.valor,
    required this.unidade,
    required this.cor,
    required this.icone,
    this.fontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: cor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Título
          Text(
            titulo,
            style: TextStyle(
              color: cor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Ícone
          Icon(icone, color: cor, size: 32),
          const SizedBox(height: 12),

          // Valor principal
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          // Unidade
          if (unidade.isNotEmpty)
            Text(
              unidade,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
