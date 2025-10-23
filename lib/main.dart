import 'package:flutter/material.dart';
import 'screens/telemetry_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '✈️ Telemetria Avião',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: const TelemetryScreen(),
    );
  }
}
