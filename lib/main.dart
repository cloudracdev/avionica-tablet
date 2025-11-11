import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
// import 'screens/login_screen.dart'; // ⏸️ Desabilitado temporariamente
import 'screens/websocket_test_screen.dart'; // 🧪 STEP 2 TEST

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
      // 🧪 STEP 2: Tela de teste WebSocket
      home: const WebSocketTestScreen(),
      // home: const LoginScreen(), // ⏸️ Voltará no STEP 5
    );
  }
}