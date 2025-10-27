import 'package:flutter/material.dart';
import 'base_instrumento.dart';

class VariometroWidget extends StatelessWidget {
  final double vario;

  const VariometroWidget({
    Key? key,
    required this.vario,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseInstrumento(
      titulo: 'VARIÔMETRO',
      valor: vario > 0 
          ? '+${vario.toStringAsFixed(1)}' 
          : vario.toStringAsFixed(1),
      unidade: 'm/s',
      cor: vario > 0 ? Colors.green : Colors.red,
      icone: vario > 0 ? Icons.arrow_upward : Icons.arrow_downward,
    );
  }
}
