import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() {
  runApp(const MedFliqApp());
}

class MedFliqApp extends StatelessWidget {
  const MedFliqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedFliq',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follows system theme
      home: const SplashScreen(),
    );
  }
}
