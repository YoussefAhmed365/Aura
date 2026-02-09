import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:aura/core/widgets/scroll_text_animation.dart';
import 'equalizer.dart';

class SongPlayerScreen extends StatefulWidget {
  const SongPlayerScreen({super.key});

  @override
  State<SongPlayerScreen> createState() => _SongPlayerScreenState();
}

class _SongPlayerScreenState extends State<SongPlayerScreen> {
  // Variables to control slider dragging behavior to prevent stuttering
  bool _isDragging = false;
  double _dragValue = 0.0;

  // Playback mode variables (Shuffle/Repeat)
  int _playModeController = 0;
  IconData _playModeIcon = Icons.repeat_rounded;
  final List<String> _modeToolTip = ['Shuffle Mode Is Off', 'Shuffle Mode Is On'];

  // Dynamic background variables
  List<Color> _bgColors = [const Color(0xFF2E1C4E), Colors.black];
  int _currentSongId = 0;

  @override
  void initState() {
    super.initState();
    // Try loading the color for the current song when opening the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<PlayerBloc>().state;
      final songId = _getSongId(state.currentSong?.id);
      if (songId != 0) {
        _updatePalette(songId);
        _currentSongId = songId;
      }
    });
  }

  // Function to extract dominant color from song artwork
  Future<void> _updatePalette(int songId) async {
    final OnAudioQuery audioQuery = OnAudioQuery();
    try {
      // 1. Get image as Bytes
      final Uint8List? artworkBytes = await audioQuery.queryArtwork(songId, ArtworkType.AUDIO);

      if (artworkBytes != null) {
        // 2. Create PaletteGenerator from image
        final PaletteGenerator palette = await PaletteGenerator.fromImageProvider(MemoryImage(artworkBytes));

        // 3. Choose best color (Dominant, Dark, or Vibrant)
        // We use darkMutedColor first as it suits dark backgrounds, then dominant
        final Color? extractedColor = palette.darkMutedColor?.color ?? palette.dominantColor?.color ?? palette.darkVibrantColor?.color;

        if (extractedColor != null) {
          setState(() {
            _bgColors = [extractedColor, Colors.black];
          });
          return;
        }
      }
    } catch (e) {
      debugPrint("Error generating palette: $e");
    }

    // Revert to default color in case of failure or no image
    setState(() {
      _bgColors = [const Color(0xFF2E1C4E), Colors.black];
    });
  }

  void _changePlayMode() {
    setState(() {
      _playModeController++;
      if (_playModeController > 1) {
        _playModeController = 0;
      }

      switch (_playModeController) {
        case 0:
          _playModeIcon = Icons.arrow_forward_ios_rounded;
          break;
        case 1:
          _playModeIcon = Icons.shuffle_rounded;
          break;
        default:
          _playModeIcon = Icons.arrow_forward_ios_rounded;
          break;
      }
    });

    _showSystemToast(_modeToolTip[_playModeController]);
  }

  void _showSystemToast(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: const Color(0xCC000000), textColor: Colors.white, fontSize: 14.0);
  }

  // Helper function to format duration (00:00)
  String _formatDuration(Duration? duration) {
    if (duration == null) return "--:--";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inMinutes}:$seconds";
  }

  // Extract Song ID for artwork
  int _getSongId(String? songUri) {
    if (songUri == null) return 0;
    String idString = songUri.split('/').last;
    try {
      return int.parse(idString);
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlayerBloc, PlayerState>(
      listener: (context, state) {
        // Check if song changed to update background color
        final newId = _getSongId(state.currentSong?.id);
        if (newId != _currentSongId) {
          _currentSongId = newId;
          _updatePalette(newId);
        }
      },
      builder: (context, state) {
        final currentSong = state.currentSong;
        final duration = state.duration;
        final position = state.position;

        // Slider logic: Use local value while dragging, player value otherwise
        double sliderValue = _isDragging ? _dragValue : position.inMilliseconds.toDouble();
        double maxDuration = duration.inMilliseconds.toDouble();

        // Prevent errors if values are zero or negative
        if (maxDuration <= 0) maxDuration = 1.0;
        if (sliderValue > maxDuration) sliderValue = maxDuration;
        if (sliderValue < 0) sliderValue = 0;

        // Song Data
        final songTitle = currentSong?.title ?? "No Song Playing";
        final songArtist = currentSong?.artist ?? "Unknown Artist";
        final songId = _getSongId(currentSong?.id);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Dynamic Background Gradient
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000), // Smooth transition between colors
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: _bgColors),
                ),
              ),

              // Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.onSurface, size: 35),
                            ),
                            TextButton(onPressed: () {}, child: Text("Now Playing", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface, letterSpacing: 1.5))),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Album Art
                      Hero(
                        tag: 'current_song_image',
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.43,
                          width: 320,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: _bgColors[0].withAlpha(102), blurRadius: 30, spreadRadius: 5)],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: QueryArtworkWidget(
                              id: songId,
                              type: ArtworkType.AUDIO,
                              artworkHeight: MediaQuery.of(context).size.height * 0.43,
                              artworkWidth: 320,
                              artworkFit: BoxFit.cover,
                              keepOldArtwork: true,
                              // --- High Quality Settings ---
                              quality: 100,
                              // Request highest JPEG quality
                              artworkQuality: FilterQuality.high,
                              // Better rendering quality
                              size: 1000,
                              // Request a larger image size (not thumbnail)
                              // -----------------------------
                              nullArtworkWidget: Container(
                                color: Colors.grey[850],
                                child: const Icon(Icons.music_note, size: 80, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Song Info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            // Song Title
                            ScrollingText(
                              text: songTitle,
                              alignment: Alignment.center,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              songArtist,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white60),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Function Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(onPressed: () {}, icon: Icon(Icons.favorite_outline_rounded), color: Theme.of(context).colorScheme.onSurface),
                          IconButton(onPressed: () {}, icon: Icon(Icons.info_outline_rounded), color: Theme.of(context).colorScheme.onSurface),
                          IconButton(onPressed: () {}, icon: Icon(Icons.subtitles), color: Theme.of(context).colorScheme.onSurface),
                          IconButton(onPressed: () {}, icon: Icon(Icons.playlist_add), color: Theme.of(context).colorScheme.onSurface),
                          IconButton(onPressed: () {}, icon: Icon(Icons.share_rounded), color: Theme.of(context).colorScheme.onSurface),
                        ],
                      ),

                      // Slider & Duration
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Theme.of(context).colorScheme.onSurface,
                                inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withAlpha(76),
                                thumbColor: Theme.of(context).colorScheme.onSurface,
                                trackShape: const RoundedRectSliderTrackShape(),
                                trackHeight: 4.0,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0, elevation: 0),
                                overlayColor: Theme.of(context).colorScheme.onSurface.withAlpha(26),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                              ),
                              child: Slider(
                                value: sliderValue,
                                min: 0.0,
                                max: maxDuration,
                                onChangeStart: (value) {
                                  setState(() {
                                    _isDragging = true;
                                    _dragValue = value;
                                  });
                                },
                                onChanged: (double value) {
                                  setState(() {
                                    _dragValue = value;
                                  });
                                },
                                onChangeEnd: (value) {
                                  // Send seek event when slider is released
                                  context.read<PlayerBloc>().add(SeekEvent(Duration(milliseconds: value.toInt())));
                                  setState(() {
                                    _isDragging = false;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(_isDragging ? Duration(milliseconds: _dragValue.toInt()) : position),
                                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                  Text(_formatDuration(duration), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const EqualizerScreen()));
                            },
                            icon: const Icon(Icons.equalizer_rounded, size: 28),
                            color: Theme.of(context).colorScheme.secondary,
                          ),

                          // Skip Previous
                          IconButton(onPressed: () => context.read<PlayerBloc>().add(SkipPreviousEvent()), icon:  Icon(Icons.skip_previous_rounded, size: 40), color: Theme.of(context).colorScheme.onSurface),

                          // Play / Pause
                          IconButton.filled(
                            style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.onSurface, foregroundColor: Theme.of(context).colorScheme.surface),
                            onPressed: () {
                              context.read<PlayerBloc>().add(PlayPauseEvent());
                            },
                            iconSize: 40,
                            icon: Icon(state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                          ),

                          // Skip Next
                          IconButton(onPressed: () => context.read<PlayerBloc>().add(SkipNextEvent()), icon:  Icon(Icons.skip_next_rounded, size: 40), color: Theme.of(context).colorScheme.onSurface),

                          // Mode Button
                          Tooltip(
                            message: _modeToolTip[_playModeController],
                            child: IconButton(onPressed: _changePlayMode, icon: Icon(_playModeIcon, size: 28), color: Theme.of(context).colorScheme.secondary, padding:  EdgeInsets.all(16)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
