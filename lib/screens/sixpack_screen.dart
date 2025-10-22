import 'package:flutter/material.dart';

class SixPackScreen extends StatelessWidget {
  const SixPackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🔴 🟢 🔵 Linha 1
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final side = constraints.maxHeight; // 1:1 com a altura
                    return SizedBox.square(
                      dimension: side,
                      child: Container(color: Colors.redAccent),
                    );
                  },
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final side = constraints.maxHeight;
                    return SizedBox.square(
                      dimension: side,
                      child: Container(color: Colors.greenAccent),
                    );
                  },
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final side = constraints.maxHeight;
                    return SizedBox.square(
                      dimension: side,
                      child: Container(color: Colors.blueAccent),
                    );
                  },
                ),
              ],
            ),
          ),
          // 🟠 🟣 🟡 Linha 2
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final side = constraints.maxHeight;
                    return SizedBox.square(
                      dimension: side,
                      child: Container(color: Colors.orangeAccent),
                    );
                  },
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final side = constraints.maxHeight;
                    return SizedBox.square(
                      dimension: side,
                      child: Container(color: Colors.purpleAccent),
                    );
                  },
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final side = constraints.maxHeight;
                    return SizedBox.square(
                      dimension: side,
                      child: Container(color: Colors.yellowAccent),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}