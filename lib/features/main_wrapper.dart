import 'package:aura/core/widgets/mini_player.dart';
import 'package:flutter/material.dart';
import 'package:aura/features/home/presentation/home_page.dart';
import 'package:aura/features/songs/presentation/songs_page.dart';
import 'package:aura/features/playlists/presentation/playlists_page.dart';
import 'package:aura/features/search/presentation/search_page.dart';
import 'package:aura/features/settings/presentation/settings_page.dart';

class MainWrapperPage extends StatefulWidget {
  const MainWrapperPage({super.key});

  @override
  State<MainWrapperPage> createState() => _MainWrapperPageState();
}

class _MainWrapperPageState extends State<MainWrapperPage> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final Container background;

    if (isDarkMode) {
      background = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [const Color(0xFF2E1C4E), Colors.black]),
        ),
      );
    } else {
      background = Container(color: Colors.white);
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Color
          background,

          // Page Content
          SafeArea(
            child: PageView(controller: _pageController, onPageChanged: _onPageChanged, physics: const PageScrollPhysics(), children: const [HomePage(), SongsPage(), PlaylistsPage(), SearchPage(), SettingsPage()]),
          ),

          // Mini Player
          Positioned(bottom: -10, left: 0, right: 0, child: MiniPlayer()),
        ],
      ),

      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onBottomNavTapped,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.music_note_outlined), selectedIcon: Icon(Icons.music_note_rounded), label: 'Songs'),
            NavigationDestination(icon: Icon(Icons.library_music_outlined), selectedIcon: Icon(Icons.library_music_rounded), label: 'Playlists'),
            NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search_rounded), label: 'Search'),
            NavigationDestination(icon: Icon(Icons.settings), selectedIcon: Icon(Icons.settings_rounded), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
