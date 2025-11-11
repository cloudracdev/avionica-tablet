import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
// import 'screens/login_screen.dart'; // ⏸️ Desabilitado temporariamente
import 'screens/telemetry_test_screen.dart'; // 🧪 STEP 3 TEST

void main() {
  runApp(
    // 🎯 RIVERPOD: Wrapper necessário para providers funcionarem
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// QFLY Flight Instruction System main application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      // 🧪 STEP 3: Tela de teste Telemetry Provider
      home: const TelemetryTestScreen(),
      // 📝 TODO STEP 5: Fluxo direto ConnectionScreen → CalibrationDialog → SixPackScreen
    );
  }
}