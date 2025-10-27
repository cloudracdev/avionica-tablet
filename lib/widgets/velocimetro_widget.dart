import 'package:flutter/material.dart';
import 'base_instrumento.dart';

class VelocimetroWidget extends StatelessWidget {
  final double velocidade;

  const VelocimetroWidget({
    Key? key,
    required this.velocidade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseInstrumento(
      titulo: 'VELOCIDADE',
      valor: velocidade.toStringAsFixed(1),
      unidade: 'km/h',
      cor: Colors.green,
      icone: Icons.speed,
    );
  }
}
