import 'package:aura/core/services/get_song_id.dart';
import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongPageview extends StatefulWidget {
  final List<Color> bgColors;
  const SongPageview({super.key, required this.bgColors});

  @override
  State<SongPageview> createState() => _SongPageviewState();
}

class _SongPageviewState extends State<SongPageview> {
  late PageController _pageController;
  bool _isProgrammaticScroll = false;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<PlayerBloc, PlayerState>(
      listenWhen: (previous, current) => previous.currentIndex != current.currentIndex,
      listener: (context, state) async {
        if (_pageController.hasClients) {
          final currentPage = _pageController.page?.round() ?? 0;

          if (currentPage != state.currentIndex) {
            _isProgrammaticScroll = true;

            if ((currentPage - state.currentIndex).abs() > 1) {
              _pageController.jumpToPage(state.currentIndex);
            } else {
              await _pageController.animateToPage(
                state.currentIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }

            await Future.delayed(const Duration(milliseconds: 100));
            _isProgrammaticScroll = false;
          }
        }
      },
      buildWhen: (previous, current) =>
          previous.queue != current.queue ||
          previous.isPlaying != current.isPlaying ||
          previous.currentIndex != current.currentIndex,
      builder: (context, state) {
        if (state.currentSong == null || state.queue.isEmpty) {
          return _buildPlaceholder(context, isDarkTheme);
        }

        if (_isInit && _pageController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(state.currentIndex);
              _isInit = false;
            }
          });
        }

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.43,
          child: PageView.builder(
            controller: _pageController,
            itemCount: state.queue.length,
            onPageChanged: (index) {
              if (_isProgrammaticScroll) return;

              final currentState = context.read<PlayerBloc>().state;
              if (currentState.currentIndex == index) return;

              final int length = currentState.queue.length;

              if (currentState.currentIndex == length - 1 && index == 0) {
                context.read<PlayerBloc>().add(SkipNextEvent());
              } else if (currentState.currentIndex == 0 && index == length - 1) {
                context.read<PlayerBloc>().add(SkipPreviousEvent());
              } else if (index > currentState.currentIndex) {
                context.read<PlayerBloc>().add(SkipNextEvent());
              } else if (index < currentState.currentIndex) {
                context.read<PlayerBloc>().add(SkipPreviousEvent());
              }
            },
            itemBuilder: (context, index) {
              final song = state.queue[index];
              final songId = getSongId(song.id);
              final isCurrent = index == state.currentIndex;

              return AnimatedScale(
                scale: (isCurrent && state.isPlaying) ? 0.95 : 0.9,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: GestureDetector(
                  onTap: () {
                    if (isCurrent) {
                      context.read<PlayerBloc>().add(PlayPauseEvent());
                    }
                  },
                  child: _buildArtworkWidget(
                    context,
                    songId,
                    MediaQuery.of(context).size.height * 0.43,
                    320,
                    isCurrent: isCurrent,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context, bool isDarkTheme) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.43,
      width: 350,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        boxShadow: [
          BoxShadow(
            color: isDarkTheme ? widget.bgColors[0].withAlpha(100) : widget.bgColors[0].withAlpha(50),
            blurRadius: 30,
            spreadRadius: 5,
          )
        ],
        borderRadius: BorderRadius.circular(50),
      ),
      child: Icon(Icons.music_note_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 100),
    );
  }

  Widget _buildArtworkWidget(BuildContext context, int songId, double height, double width, {bool isCurrent = false}) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: isDarkTheme ? widget.bgColors[0].withAlpha(100) : widget.bgColors[0].withAlpha(50),
                  blurRadius: 30,
                  spreadRadius: 5,
                )
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: QueryArtworkWidget(
          id: songId,
          type: ArtworkType.AUDIO,
          artworkHeight: height,
          artworkWidth: width,
          artworkFit: BoxFit.cover,
          keepOldArtwork: true,
          quality: 100,
          artworkQuality: FilterQuality.high,
          size: 1000,
          nullArtworkWidget: Container(
            height: height,
            width: width,
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: Icon(Icons.music_note, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
