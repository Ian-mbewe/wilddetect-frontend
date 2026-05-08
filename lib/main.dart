import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const WildDetectApp());
}

class WildDetectApp extends StatelessWidget {
  const WildDetectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WildDetect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D6A4F)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}