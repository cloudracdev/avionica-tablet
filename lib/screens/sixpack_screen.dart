import 'package:flutter/material.dart';

class SixPackScreen extends StatelessWidget {
  const SixPackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Primeira linha
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 100, height: 100, color: Colors.redAccent),
                const SizedBox(width: 20),
                Container(width: 100, height: 100, color: Colors.greenAccent),
                const SizedBox(width: 20),
                Container(width: 100, height: 100, color: Colors.blueAccent),
              ],
            ),
            const SizedBox(height: 20),
            // Segunda linha
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 100, height: 100, color: Colors.orangeAccent),
                const SizedBox(width: 20),
                Container(width: 100, height: 100, color: Colors.purpleAccent),
                const SizedBox(width: 20),
                Container(width: 100, height: 100, color: Colors.yellowAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}