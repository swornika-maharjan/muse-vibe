import 'package:client/core/providers/audio_manager.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:just_audio/just_audio.dart';
part 'current_song_notifier.g.dart';

@riverpod
class CurrentSongNotifier extends _$CurrentSongNotifier {
  late HomeLocalRepository _homeLocalRepository;
  AudioPlayer audioPlayer = AudioManager.instance;

  bool isPlaying = false;
  List<SongModel> _currentPlaylist = [];

  @override
  SongModel? build() {
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    return null;
  }

  void dispose() {
    audioPlayer.dispose(); // Dispose the AudioPlayer instance
  }

  void updatePlaylist(List<SongModel> playlist) {
    _currentPlaylist = playlist;
  }

  void updateSong(SongModel song) async {
    await audioPlayer.stop();
    audioPlayer = AudioManager.instance;

    final audioSource = AudioSource.uri(
      Uri.parse(song.song_url),
      tag: MediaItem(
        id: song.id,
        title: song.song_name,
        artist: song.artist,
        artUri: Uri.parse(song.thumbnail_url),
      ),
    );
    await audioPlayer.setAudioSource(audioSource);

    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playNextSongAutomatically();
      }
    });

    _homeLocalRepository.uploadLocalSong(song);
    audioPlayer.play();
    isPlaying = true;
    state = song;
  }

  void _playNextSongAutomatically() {
    final currentIndex =
        _currentPlaylist.indexWhere((song) => song.id == state?.id);
    if (currentIndex >= 0 && currentIndex < _currentPlaylist.length - 1) {
      playNext(_currentPlaylist[currentIndex + 1]);
    }
  }

  void playPause() {
    if (isPlaying) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
    isPlaying = !isPlaying;
    state = state?.copyWith(hex_code: state?.hex_code);
  }

  void seek(double val) {
    audioPlayer.seek(
      Duration(
        milliseconds: (val * audioPlayer.duration!.inMilliseconds).toInt(),
      ),
    );
  }

  void playNext(SongModel nextSong) async {
    await audioPlayer.stop();
    audioPlayer = AudioManager.instance;

    final audioSource = AudioSource.uri(
      Uri.parse(nextSong.song_url),
      tag: MediaItem(
        id: nextSong.id,
        title: nextSong.song_name,
        artist: nextSong.artist,
        artUri: Uri.parse(nextSong.thumbnail_url),
      ),
    );

    await audioPlayer.setAudioSource(audioSource);
    audioPlayer.play();
    isPlaying = true;
    state = nextSong;
    _homeLocalRepository.uploadLocalSong(nextSong);
  }

  void playPrevious(SongModel previousSong) async {
    await audioPlayer.stop();
    audioPlayer = AudioManager.instance;

    final audioSource = AudioSource.uri(
      Uri.parse(previousSong.song_url),
      tag: MediaItem(
        id: previousSong.id,
        title: previousSong.song_name,
        artist: previousSong.artist,
        artUri: Uri.parse(previousSong.thumbnail_url),
      ),
    );

    await audioPlayer.setAudioSource(audioSource);
    audioPlayer.play();
    isPlaying = true;
    state = previousSong;
    _homeLocalRepository.uploadLocalSong(previousSong);
  }

  Future<void> stop() async {
    await audioPlayer.stop(); // Stops the music playback
    isPlaying = false;
  }

  void clearCurrentSong() {
    state = null; // Resets the current song
  }
}
