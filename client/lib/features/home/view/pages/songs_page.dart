import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SongsPage extends ConsumerStatefulWidget {
  const SongsPage({super.key});

  @override
  ConsumerState<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends ConsumerState<SongsPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentSong = ref.watch(currentSongNotifierProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: currentSong == null
          ? null
          : BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  hexToColor(currentSong.hex_code),
                  Pallete.transparentColor,
                ],
                stops: const [0.0, 0.3],
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar in AppBar
          AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: Container(
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(30.0), // Circular border
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),

          // All and Recommended Tabs
          DefaultTabController(
            length: 2,
            child: Expanded(
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.indigo,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.indigo,
                    tabs: [
                      Tab(text: 'All'),
                      Tab(text: 'Recommended'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // All Songs Vertical List
                        ref.watch(getAllSongsProvider).when(
                              data: (songs) {
                                final filteredSongs = songs
                                    .where((song) =>
                                        song.song_name
                                            .toLowerCase()
                                            .contains(_searchQuery) ||
                                        song.artist
                                            .toLowerCase()
                                            .contains(_searchQuery))
                                    .toList();

                                return ListView.builder(
                                  padding: const EdgeInsets.all(8.0),
                                  itemCount: filteredSongs.length,
                                  itemBuilder: (context, index) {
                                    final song = filteredSongs[index];
                                    return GestureDetector(
                                      onTap: () {
                                        ref
                                            .read(currentSongNotifierProvider
                                                .notifier)
                                            .updateSong(song);
                                      },
                                      child: Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: ListTile(
                                          leading: Image.network(
                                            song.thumbnail_url,
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                          ),
                                          title: Text(
                                            song.song_name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Text(
                                            song.artist,
                                            style: const TextStyle(
                                              color: Pallete.subtitleText,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              error: (error, st) => Center(
                                child: Text(error.toString()),
                              ),
                              loading: () => const Loader(),
                            ),
                        // Recommended Songs Vertical List
                        ref.watch(getRecommendedSongsProvider).when(
                              data: (songs) {
                                final filteredSongs = songs
                                    .where((song) =>
                                        song.song_name
                                            .toLowerCase()
                                            .contains(_searchQuery) ||
                                        song.artist
                                            .toLowerCase()
                                            .contains(_searchQuery))
                                    .toList();

                                return ListView.builder(
                                  padding: const EdgeInsets.all(8.0),
                                  itemCount: filteredSongs.length,
                                  itemBuilder: (context, index) {
                                    final song = filteredSongs[index];
                                    return GestureDetector(
                                      onTap: () {
                                        ref
                                            .read(currentSongNotifierProvider
                                                .notifier)
                                            .updateSong(song);
                                      },
                                      child: Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: ListTile(
                                          leading: Image.network(
                                            song.thumbnail_url,
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                          ),
                                          title: Text(
                                            song.song_name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Text(
                                            song.artist,
                                            style: const TextStyle(
                                              color: Pallete.subtitleText,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              error: (error, st) => Center(
                                child: Text(error.toString()),
                              ),
                              loading: () => const Loader(),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
