// playback_page.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlaybackPage extends StatefulWidget {
  final String trackUrl;
  final String coverUrl;
  final String trackName;
  final String artistName;

  const PlaybackPage({
    Key? key,
    required this.trackUrl,
    required this.coverUrl,
    required this.trackName,
    required this.artistName,
  }) : super(key: key);

  @override
  PlaybackPageState createState() => PlaybackPageState();
}

class PlaybackPageState extends State<PlaybackPage> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _playMusic();
  }

  Future<void> _playMusic() async {
    await _player.setSourceUrl(widget.trackUrl);
    await _player.resume();
    setState(() {
      isPlaying = true;
    });
  }

  @override
  void dispose() {
    _player.dispose(); // Dispose player when page is closed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trackName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(widget.coverUrl, height: 200),
            const SizedBox(height: 20),
            Text(widget.trackName, style: const TextStyle(fontSize: 24)),
            Text(widget.artistName, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (isPlaying) {
                  _player.pause();
                } else {
                  _player.resume();
                }
                setState(() {
                  isPlaying = !isPlaying; // Toggle play/pause
                });
              },
              child: Text(isPlaying ? 'Pause' : 'Play'),
            ),
          ],
        ),
      ),
    );
  }
}
