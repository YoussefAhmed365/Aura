import 'package:aura/core/di/injection.dart';
import 'package:aura/core/widgets/mini_player.dart';
import 'package:aura/core/widgets/sliver_list_tile.dart';
import 'package:aura/features/music_player/domain/repositories/audio_repository.dart';
import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../main_wrapper.dart';

class SongListByEntity extends StatefulWidget {
  final int id;
  final String title;
  final bool isArtist;
  final bool isPlaylist; // Added to support Playlist viewing seamlessly

  const SongListByEntity({super.key, required this.id, required this.title, required this.isArtist, this.isPlaylist = false});

  @override
  State<SongListByEntity> createState() => _SongListByEntityState();
}

class _SongListByEntityState extends State<SongListByEntity> {
  late Future<List<SongModel>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture();
  }

  @override
  void didUpdateWidget(covariant SongListByEntity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id ||
        oldWidget.isPlaylist != widget.isPlaylist ||
        oldWidget.isArtist != widget.isArtist) {
      _loadFuture();
    }
  }

  void _loadFuture() {
    _songsFuture = widget.isPlaylist
        ? getIt<AudioRepository>().getSongsByPlaylist(widget.id)
        : widget.isArtist
            ? getIt<AudioRepository>().getSongsByArtist(widget.id)
            : getIt<AudioRepository>().getSongsByAlbum(widget.id);
  }

  void _onBottomNavTapped(int index) {
    // Navigation logic
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        // Pass the 'index' from the NavigationBar to the MainWrapperPage constructor
        builder: (context) => MainWrapperPage(index: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final Container background;

    if (isDarkMode) {
      background = Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2E1C4E), Colors.black]),
        ),
      );
    } else {
      background = Container(color: Colors.white);
    }

    return Scaffold(
      body: Stack(
        children: [
          background,
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.keyboard_arrow_left_rounded, color: Theme.of(context).colorScheme.inverseSurface, size: 35),
                      ),
                      Expanded(
                        child: Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.inverseSurface, letterSpacing: 1.5)
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.inverseSurface),
                      ),
                    ],
                  ),
                ),
                SliverListTile(
                  future: _songsFuture,
                  artworkType: ArtworkType.AUDIO,
                  title: (song) => song.title,
                  subtitle: (song) => "${song.artist ?? "Unknown"} • ${song.album ?? "Unknown"}",
                  id: (song) => song.id,
                  onTap: (list, index) {
                    context.read<PlayerBloc>().add(PlayAllEvent(songs: list, index: index));
                  },
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100), // Padding for MiniPlayer
                )
              ],
            ),
          ),

          Positioned(bottom: MediaQuery.of(context).size.height * -0.86, left: 0, right: 0, child: const MiniPlayer()),
        ],
      ),

      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        child: NavigationBar(
          selectedIndex: 1,
          onDestinationSelected: _onBottomNavTapped,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.music_note_outlined), selectedIcon: Icon(Icons.music_note_rounded), label: 'Songs'),
            NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search_rounded), label: 'Search'),
            NavigationDestination(icon: Icon(Icons.settings), selectedIcon: Icon(Icons.settings_rounded), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}