import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
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
      home: const LoginScreen(),
    );
  }
}