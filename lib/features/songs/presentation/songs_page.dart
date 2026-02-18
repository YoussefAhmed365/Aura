import 'package:aura/features/songs/widgets/albums.dart';
import 'package:aura/features/songs/widgets/artists.dart';
import 'package:aura/features/songs/widgets/playlists.dart';
import 'package:aura/features/songs/widgets/songs.dart';
import 'package:flutter/material.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  final ScrollController _songScrollController = ScrollController();
  final ScrollController _albumScrollController = ScrollController();
  final ScrollController _artistScrollController = ScrollController();
  final ScrollController _playlistScrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _songScrollController.dispose();
    _albumScrollController.dispose();
    _artistScrollController.dispose();
    _playlistScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 25),
            child: Text(
              "Music list",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color)
            ),
          ),

          // Tabs
          Container(
            alignment: Alignment.center,
            height: 50,
            child: TabBar(
              isScrollable: false,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.secondary,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: "Songs"),
                Tab(text: "Albums"),
                Tab(text: "Artists"),
                Tab(text: "Playlist"),
              ],
            ),
          ),

          // Page
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 90),
              child: TabBarView(
                children: [
                  Scrollbar(
                    controller: _songScrollController,
                    thickness: 8.0,
                    radius: const Radius.circular(10),
                    interactive: true,
                    child: CustomScrollView(key: const PageStorageKey<String>('songs'), controller: _songScrollController, slivers: const [Songs()]),
                  ),
                  Scrollbar(
                    controller: _albumScrollController,
                    thickness: 8.0,
                    radius: const Radius.circular(10),
                    interactive: true,
                    child: CustomScrollView(key: PageStorageKey<String>('albums'), slivers: [Albums()]),
                  ),
                  Scrollbar(
                    controller: _artistScrollController,
                    thickness: 8.0,
                    radius: const Radius.circular(10),
                    interactive: true,
                    child: CustomScrollView(key: PageStorageKey<String>('artists'), slivers: [Artists()]),
                  ),
                  Scrollbar(
                    controller: _playlistScrollController,
                    thickness: 8.0,
                    radius: const Radius.circular(10),
                    interactive: true,
                    child: CustomScrollView(key: PageStorageKey<String>('playlists'), slivers: [Playlists()]),
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
