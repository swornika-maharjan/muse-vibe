import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/view/pages/library_page.dart';
import 'package:client/features/home/view/pages/songs_page.dart';
import 'package:client/features/home/view/pages/upload_song_page.dart';
import 'package:client/features/home/view/widgets/music_slab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int selectedIndex = 0;

  final pages = const [
    SongsPage(),
    LibraryPage(),
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to upload page when middle icon is tapped
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const UploadSongPage(),
        ),
      );
    } else {
      setState(() {
        selectedIndex = index > 1 ? index - 1 : index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          pages[selectedIndex],
          const Positioned(
            bottom: 0,
            child: MusicSlab(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex < 1 ? selectedIndex : 1,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              selectedIndex == 0
                  ? 'assets/images/home_filled.png'
                  : 'assets/images/home_unfilled.png',
              color: selectedIndex == 0
                  ? Pallete.whiteColor
                  : Pallete.inactiveBottomBarItemColor,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                color: Pallete.whiteColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Pallete.backgroundColor,
                size: 28,
              ),
            ),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/library.png',
              color: selectedIndex == 1
                  ? Pallete.whiteColor
                  : Pallete.inactiveBottomBarItemColor,
            ),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
