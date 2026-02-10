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
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 4,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              floating: false,
              snap: false,
              elevation: 0,
              backgroundColor: isDarkMode ? const Color(0xFF281842) : Theme.of(context).colorScheme.surfaceBright,
              automaticallyImplyLeading: false,
              titleSpacing: 20,

              // "Music List" Title
              title: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Music list",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),
              centerTitle: false,

              // Tabs (Songs, Artists, Album, Playlist)
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  alignment: Alignment.center,
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
                      Tab(text: "Artists"),
                      Tab(text: "Album"),
                      Tab(text: "Playlist"),
                    ],
                    onTap: (index) {},
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [
            const CustomScrollView(key: PageStorageKey<String>('songs'), slivers: [Songs()]),
            const CustomScrollView(key: PageStorageKey<String>('artists'), slivers: [Artists()]),
            const CustomScrollView(key: PageStorageKey<String>('albums'), slivers: [Albums()]),
            const CustomScrollView(key: PageStorageKey<String>('playlists'), slivers: [Playlists()]),
          ],
        ),
      ),
    );
  }
}
