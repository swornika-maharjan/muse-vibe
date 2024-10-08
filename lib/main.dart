import 'package:flutter/material.dart';
import 'package:music_player/splash_page.dart';
import 'core/theme/theme.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MuseVibe',
      theme: AppTheme.darkThemeMode,
      home: const SplashPage(), // Set SplashPage as the initial screen
      debugShowCheckedModeBanner: false,
    );
  }
}

