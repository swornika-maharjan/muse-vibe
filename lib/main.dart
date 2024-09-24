// main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:music_player/accesstoken/token.dart'; // Import the new file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginSignupPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  LoginSignupPageState createState() => LoginSignupPageState();
}

class LoginSignupPageState extends State<LoginSignupPage> {
  bool isLogin = true; // Toggle between login and signup
  Map<String, String> registeredUsers = {}; // Store signed-up users

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Signup'),
      ),
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (isLogin) {
                    // Login logic
                    if (registeredUsers.containsKey(emailController.text) &&
                        registeredUsers[emailController.text] == passwordController.text) {
                      // Successful login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MusicListPage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login failed. Please sign up first or check credentials.')),
                      );
                    }
                  } else {
                    // Signup logic
                    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                      setState(() {
                        registeredUsers[emailController.text] = passwordController.text;
                        isLogin = true; // Switch to login mode after signup
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Signup successful! You can now login.')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in both fields to sign up.')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(isLogin ? 'Login' : 'Signup'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin; // Toggle between login and signup
                  });
                },
                child: Text(
                  isLogin ? "Don't have an account? Signup" : "Already have an account? Login",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MusicListPage extends StatefulWidget {
  const MusicListPage({super.key});

  @override
  MusicListPageState createState() => MusicListPageState();
}

class MusicListPageState extends State<MusicListPage> {
  List<dynamic> musicList = [];

  @override
  void initState() {
    super.initState();
    fetchMusic();
  }

  Future<void> fetchMusic() async {
    final accessToken = await getSpotifyAccessToken(); // Call the function from the service
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=beatles&type=track'),
      headers: {
        'Authorization': 'Bearer $accessToken', // Use the retrieved access token
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        musicList = jsonDecode(response.body)['tracks']['items'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load music')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music List'),
      ),
      body: musicList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: musicList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(musicList[index]['name']),
            subtitle: Text(musicList[index]['artists'][0]['name']),
            onTap: () {
              // Implement music playback logic here
            },
          );
        },
      ),
    );
  }
}
