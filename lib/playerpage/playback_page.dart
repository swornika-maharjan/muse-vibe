import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlaybackPage extends StatefulWidget {
  final String trackUrl;
  final String coverUrl;
  final String trackName;
  final String artistName;
  final List<Map<String, String>> playlist;
  final int currentIndex;

  const PlaybackPage({
    Key? key,
    required this.trackUrl,
    required this.coverUrl,
    required this.trackName,
    required this.artistName,
    required this.playlist,
    required this.currentIndex,
  }) : super(key: key);

  @override
  PlaybackPageState createState() => PlaybackPageState();
}

class PlaybackPageState extends State<PlaybackPage> {
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration duration = Duration.zero;
  int currentIndex = 0;
  double sliderValue = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
    audioPlayer = AudioPlayer();
    setTrack(widget.trackUrl);

    // Listen for player state changes
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    // Listen for duration changes to update the slider
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
        sliderValue = currentPosition.inSeconds.toDouble();
      });
    });

    // Update current position for the slider
    audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        currentPosition = position;
        sliderValue = position.inSeconds.toDouble();
      });
    });

    // Automatically play the next song when current finishes
    audioPlayer.onPlayerComplete.listen((_) {
      playNext();
    });
  }

  // Set the track to be played
  void setTrack(String url) async {
    if (url.startsWith('assets/songs/')) {
      await audioPlayer.setSourceAsset(url);
      play();
    }
  }

  // Play the track
  void play() async {
    await audioPlayer.resume();
  }

  // Pause the track
  void pause() async {
    await audioPlayer.pause();
  }

  // Go to next track
  void playNext() {
    setState(() {
      currentIndex = (currentIndex + 1) % widget.playlist.length;
      final nextTrack = widget.playlist[currentIndex];
      setTrack(nextTrack['filePath']!);
    });
  }

  // Go to previous track
  void playPrevious() {
    setState(() {
      currentIndex = (currentIndex - 1) < 0
          ? widget.playlist.length - 1
          : currentIndex - 1;
      final previousTrack = widget.playlist[currentIndex];
      setTrack(previousTrack['filePath']!);
    });
  }

  // Seek to a specific position
  void seekTo(double value) {
    final newPosition = Duration(seconds: value.toInt());
    audioPlayer.seek(newPosition);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = widget.playlist[currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(currentTrack['title']!),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(currentTrack['coverUrl']!,
                    height: 300, fit: BoxFit.cover),
                const SizedBox(height: 20),
                Text(currentTrack['title']!,
                    style: const TextStyle(fontSize: 24)),
                Text(currentTrack['artist']!,
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                if (duration.inSeconds > 0)
                  Column(
                    children: [
                      Slider(
                        value: sliderValue,
                        min: 0,
                        max: duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          setState(() {
                            sliderValue = value;
                          });
                        },
                        onChangeEnd: (value) {
                          seekTo(value);
                        },
                      ),
                      Text(
                        '${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')} / ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: playPrevious,
                    ),
                    IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: isPlaying ? pause : play,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: playNext,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
