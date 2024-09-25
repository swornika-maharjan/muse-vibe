// main.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:music_player/playerpage/playback_page.dart';

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
  bool isPlaying = false;
  String currentTrack = "";
  String currentCover = "";
  double value = 0;
  Duration? duration;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchMusic();
  }

  Future<String> getSpotifyAccessToken() async {
    const clientId = '4295237b56614d09b710a17c4b490da5';
    const clientSecret = 'd23b71a06f3c4eba91aa97e87f517ae1';

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic ${base64Encode(
            utf8.encode('$clientId:$clientSecret'))}',
      },
      body: {
        'grant_type': 'client_credentials',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      throw Exception('Failed to get access token');
    }
  }

  Future<void> fetchMusic() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/search?q=beatles&type=track'),
        headers: {
          'Authorization': 'Bearer  BQD14_WpNBdKQQrxoXwin2xl008MIoMmlKtKL60pUWRhCX9cwN591GjSrnJGLUx2GckaYbcpWkM3_xlnlpne8t9evk31bwG98uzYpaFEpWmCUtS-Lw8',
          // Use the actual access token
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return; // Check if the widget is still mounted
        setState(() {
          musicList = jsonDecode(response.body)['tracks']['items'];
        });
      } else {
        if (!mounted) return; // Check if the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load music')),
        );
      }
    } catch (e) {
      if (!mounted) return; // Check if the widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching music')),
      );
    }
  }

  // Function to play selected song
  void playMusic(String trackUrl, String coverUrl) async {
    await player.setSourceUrl(trackUrl);
    await player.resume();
    duration = await player.getDuration();
    setState(() {
      isPlaying = true;
      currentTrack = trackUrl;
      currentCover = coverUrl;
    });

    player.onPositionChanged.listen((position) {
      setState(() {
        value = position.inSeconds.toDouble();
      });
    });
  }

  // Function to stop the song
  void stopMusic() async {
    await player.pause();
    setState(() {
      isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('For You'),
        backgroundColor: Colors.blueAccent,
      ),
      body: musicList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: musicList.length,
        itemBuilder: (context, index) {
          // Extract track information
          final track = musicList[index];
          final trackUrl = track['preview_url']; // Preview URL for playback
          final coverUrl = track['album']['images'][0]['url']; // Cover URL

          return ListTile(
            leading: coverUrl != null
                ? Image.network(
              coverUrl, // Use the actual cover URL from API
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
                : Image.asset(
              'assets/cover1.jpg', // Fallback to default image
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(track['name']),
            subtitle: Text(track['artists'][0]['name']),
            onTap: () {
              if (trackUrl != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaybackPage(
                      trackUrl: trackUrl,
                      coverUrl: coverUrl,
                      trackName: track['name'],
                      artistName: track['artists'][0]['name'],
                    ),
                  ),
                ).then((_) {
                  // Callback to handle when returning from PlaybackPage
                  if (isPlaying) {
                    stopMusic(); // Stop playback if user returns
                  }
                });
              }
            },
          );
        },
      ),
    );
  }
}
