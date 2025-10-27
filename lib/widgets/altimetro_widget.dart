import 'package:flutter/material.dart';
import 'base_instrumento.dart';

class AltimetroWidget extends StatelessWidget {
  final double altitude;

  const AltimetroWidget({
    Key? key,
    required this.altitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseInstrumento(
      titulo: 'ALTITUDE',
      valor: altitude.toStringAsFixed(1),
      unidade: 'm',
      cor: Colors.orange,
      icone: Icons.height,
    );
  }
}
