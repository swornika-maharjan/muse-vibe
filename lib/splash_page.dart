// splash_page.dart
import 'package:flutter/material.dart';
import 'package:music_player/features/auth/view/pages/signup_page.dart';
import 'package:music_player/main.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    // Simulate a delay for the splash screen (e.g., 3 seconds)
    Future.delayed(const Duration(seconds: 3), () {
      // After the delay, navigate to the LoginSignupPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignupPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blueAccent, // Background color for splash
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'MuseVibe',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
