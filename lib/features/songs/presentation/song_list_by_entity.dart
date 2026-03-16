import 'package:aura/core/di/injection.dart';
import 'package:aura/core/widgets/mini_player.dart';
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
            child: Column(
              children: [
                Row(
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: FutureBuilder<List<SongModel>>(
                      // Switch easily between entities
                      future: _songsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || snapshot.data == null) {
                          return const Center(child: Text("Error loading songs"));
                        }

                        final songs = snapshot.data!;

                        if (songs.isEmpty) {
                          return const Center(child: Text("No songs available"));
                        }

                        return ListView.builder(
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            final song = songs[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child: InkWell(
                                onTap: () {
                                  context.read<PlayerBloc>().add(PlayAllEvent(songs: snapshot.data!, index: index));
                                },
                                splashColor: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(10),
                                child: Row(
                                  children: [
                                    // Rounded Artwork
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: QueryArtworkWidget(
                                        id: song.id,
                                        type: ArtworkType.AUDIO,
                                        artworkWidth: 60,
                                        artworkHeight: 60,
                                        keepOldArtwork: true,
                                        nullArtworkWidget: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(color: Colors.grey.withAlpha(26), borderRadius: BorderRadius.circular(15)),
                                          child: const Icon(Icons.music_note, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),

                                    // Song Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            song.title,
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${song.artist ?? "Unknown"} • ${song.album ?? "Unknown"}",
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // More Options Icon
                                    IconButton(
                                      icon: const Icon(Icons.more_horiz, color: Colors.grey),
                                      onPressed: () {
                                        // Show options menu
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
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