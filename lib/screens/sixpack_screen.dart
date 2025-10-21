import 'package:flutter/material.dart';

class SixPackScreen extends StatelessWidget {
  const SixPackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: Container(color: Colors.redAccent)),
                Expanded(child: Container(color: Colors.greenAccent)),
                Expanded(child: Container(color: Colors.blueAccent)),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(child: Container(color: Colors.orangeAccent)),
                Expanded(child: Container(color: Colors.purpleAccent)),
                Expanded(child: Container(color: Colors.yellowAccent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}