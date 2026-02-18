import 'package:aura/core/widgets/scroll_text_animation.dart';
import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:aura/features/music_player/presentation/song_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  String? _lastSongId;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  int _getSongId(String songId) {
    try {
      return int.parse(songId);
    } catch (e) {
      return 0;
    }
  }

  void _showPlayer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SongPlayerScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Defines the start (bottom of screen) and end (top of screen)
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;

          // Use a smooth curve like easeInOutCubic or fastOutSlowIn
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        // Optional: adjust the duration of the transition
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlayerBloc, PlayerState>(
      listenWhen: (previous, current) {
        return previous.isPlaying != current.isPlaying || previous.currentSong != current.currentSong;
      },
      listener: (context, state) {
        if (_lastSongId != state.currentSong?.id) {
          _rotationController.reset();
          _lastSongId = state.currentSong?.id;
        }

        if (state.isPlaying && state.currentSong != null) {
          if (!_rotationController.isAnimating) {
            _rotationController.repeat();
          }
        } else {
          _rotationController.stop();
        }
      },
      buildWhen: (previous, current) {
        return previous.currentSong != current.currentSong || previous.isPlaying != current.isPlaying;
      },
      builder: (context, state) {
        final song = state.currentSong;
        final bool hasSong = song != null;

        final songId = hasSong ? _getSongId(song.id) : 0;
        final songTitle = hasSong ? song.title : "Aura Music";
        final artist = hasSong ? (song.artist ?? "Unknown") : "Choose a song";

        return GestureDetector(
          onTap: () {
            _showPlayer(context);
          },
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! < -300) {
              _showPlayer(context);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(topRight: Radius.circular(40), topLeft: Radius.circular(40)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Song Image
                      RotationTransition(
                        turns: _rotationController,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(0),
                          child: QueryArtworkWidget(
                            id: songId,
                            type: ArtworkType.AUDIO,
                            artworkHeight: 50,
                            artworkWidth: 50,
                            artworkFit: BoxFit.cover,
                            keepOldArtwork: true,
                            nullArtworkWidget: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.surfaceContainerHigh),
                              child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Song Name & Artist
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ScrollingText(text: songTitle, isMiniPlayer: true, style: Theme.of(context).textTheme.titleMedium),
                            Text(artist, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Control Buttons
                Row(
                  children: [
                    IconButton(onPressed: hasSong ? () => context.read<PlayerBloc>().add(SkipPreviousEvent()) : null, icon: const Icon(Icons.skip_previous, size: 30)),
                    IconButton(
                      onPressed: hasSong
                          ? () {
                              context.read<PlayerBloc>().add(PlayPauseEvent());
                            }
                          : null,
                      icon: Icon(state.isPlaying ? Icons.pause_circle : Icons.play_circle, size: 35),
                    ),
                    IconButton(onPressed: hasSong ? () => context.read<PlayerBloc>().add(SkipNextEvent()) : null, icon: const Icon(Icons.skip_next, size: 30)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
