import 'dart:typed_data';
import 'package:aura/core/widgets/scroll_text_animation.dart';
import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator_master/palette_generator_master.dart';

import 'equalizer.dart';

class SongPlayerScreen extends StatefulWidget {
  const SongPlayerScreen({super.key});

  @override
  State<SongPlayerScreen> createState() => _SongPlayerScreenState();
}

class _SongPlayerScreenState extends State<SongPlayerScreen> {
  late PageController _pageController;

  // Variables to control slider dragging behavior
  bool _isDragging = false;
  double _dragValue = 0.0;
  bool _showRemaining = false;

  // علم لتحديد ما إذا كان التحريك برمجياً (لمنع الحلقات المفرغة)
  bool _isProgrammaticScroll = false;

  // Playback mode variables
  int _playModeController = 0;
  IconData _playModeIcon = Icons.arrow_forward_ios_rounded;
  final List<String> _modeToolTip = ['Shuffle Mode Is Off', 'Shuffle Mode Is On'];

  // Dynamic background variables
  List<Color> _bgColors = [const Color(0xFFF3E5F5), Colors.white];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // التحقق من الوضع الحالي (فاتح أم مظلم)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark && _bgColors[0] == const Color(0xFFF3E5F5)) {
      _bgColors = [const Color(0xFF2E1C4E), Colors.black];
    }
  }

  int _currentSongId = 0;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final state = context.read<PlayerBloc>().state;

      if (_pageController.hasClients) {
        _pageController.jumpToPage(state.currentIndex);
      }

      final songId = _getSongId(state.currentSong?.id);
      if (songId != 0) {
        _updatePalette(songId, isDark);
        _currentSongId = songId;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Function to extract dominant color from song artwork
  Future<void> _updatePalette(int songId, bool isDarkTheme) async {
    final OnAudioQuery audioQuery = OnAudioQuery();
    try {
      // 1. Get image as Bytes
      final Uint8List? artworkBytes = await audioQuery.queryArtwork(songId, ArtworkType.AUDIO);

      if (artworkBytes != null) {
        final PaletteGeneratorMaster palette = await PaletteGeneratorMaster.fromImageProvider(MemoryImage(artworkBytes));
        final Color? extractedColor = isDarkTheme ? (palette.darkMutedColor?.color ?? palette.dominantColor?.color ?? palette.darkVibrantColor?.color) : (palette.lightVibrantColor?.color ?? palette.vibrantColor?.color ?? palette.lightMutedColor?.color ?? palette.dominantColor?.color);

        if (extractedColor != null) {
          if (mounted) {
            setState(() {
              _bgColors = [extractedColor, isDarkTheme ? Colors.black : Colors.white];
            });
          }
          return;
        }
      }
    } catch (e) {
      debugPrint("Error generating palette: $e");
    }

    // Revert to default color in case of failure or no image
    if (mounted) {
      setState(() {
        _bgColors = isDarkTheme ? [const Color(0xFF2E1C4E), Colors.black] : [const Color(0xFFF3E5F5), Colors.white];
      });
    }
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
    // This checks if the current theme is dark
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    final iconColor = isDarkTheme ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.inverseSurface;

    return Dismissible(
      key: const Key('player_dismiss_key'),
      direction: DismissDirection.down,
      onDismissed: (_) {
        Navigator.pop(context);
      },
      background: const ColoredBox(color: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Background
            BlocListener<PlayerBloc, PlayerState>(
              listenWhen: (previous, current) => previous.currentSong?.id != current.currentSong?.id,
              listener: (context, state) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final newId = _getSongId(state.currentSong?.id);
                if (newId != _currentSongId) {
                  _currentSongId = newId;
                  _updatePalette(newId, isDark);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: _bgColors),
                ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.inverseSurface, size: 35),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text("Now Playing", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.inverseSurface, letterSpacing: 1.5)),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.inverseSurface),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Album Art - Optimized
                    BlocConsumer<PlayerBloc, PlayerState>(
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
                      // FIX: إضافة previous.currentIndex != current.currentIndex لشرط إعادة البناء
                      // هذا يضمن أن الصور يتم تحديث حالتها (كبيرة/صغيرة/قابلة للمس) عند تغيير الأغنية
                      buildWhen: (previous, current) =>
                      previous.queue != current.queue ||
                          previous.isPlaying != current.isPlaying ||
                          previous.currentIndex != current.currentIndex,
                      builder: (context, state) {
                        // التحقق من وجود أغاني
                        if (state.currentSong == null || state.queue.isEmpty) {
                          return _buildPlaceholder(context, isDarkTheme);
                        }

                        if (_isInit && _pageController.hasClients) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if(_pageController.hasClients) {
                              _pageController.jumpToPage(state.currentIndex);
                              _isInit = false;
                            }
                          });
                        }

                        // نستخدم ValueKey لإجبار الـ PageView على إعادة البناء عند تغير الأغنية
                        // هذا يعيدنا للصفحة رقم 1 (المنتصف) تلقائياً عند تشغيل أغنية جديدة
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
                              }
                              else if (currentState.currentIndex == 0 && index == length - 1) {
                                context.read<PlayerBloc>().add(SkipPreviousEvent());
                              }
                              else if (index > currentState.currentIndex) {
                                context.read<PlayerBloc>().add(SkipNextEvent());
                              }
                              else if (index < currentState.currentIndex) {
                                context.read<PlayerBloc>().add(SkipPreviousEvent());
                              }
                            },
                            itemBuilder: (context, index) {
                              final song = state.queue[index];
                              final songId = _getSongId(song.id);
                              final isCurrent = index == state.currentIndex;

                              return AnimatedScale(
                                scale: (isCurrent && state.isPlaying) ? 0.95 : 0.9,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: GestureDetector(
                                  // استخدام دالة مجهولة بدلاً من شرط null
                                  // هذا يضمن أن الـ Listener موجود دائماً ويتم التحقق من الشرط عند الضغط
                                  onTap: () {
                                    if (isCurrent) {
                                      context.read<PlayerBloc>().add(PlayPauseEvent());
                                    }
                                  },
                                  child: _buildArtworkWidget(context, songId, MediaQuery.of(context).size.height * 0.43, 320, isCurrent: isCurrent),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Song Info
                    BlocSelector<PlayerBloc, PlayerState, ({String title, String album, String artist})>(
                      selector: (state) => (title: state.currentSong?.title ?? "No Song Playing", album: state.currentSong?.album ?? "Unknown Album", artist: state.currentSong?.artist ?? "Unknown Artist"),
                      builder: (context, info) {
                        return Column(
                          children: [
                            SizedBox(
                              height: 40,
                              child: ScrollingText(
                                text: info.title,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 3),
                            SizedBox(
                              height: 25,
                              child: Text(
                                info.album,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              height: 25,
                              child: Text(
                                info.artist,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Function Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(onPressed: () {}, icon: Icon(Icons.favorite_outline_rounded, size: 25), color: iconColor),
                          IconButton(onPressed: () {}, icon: Icon(Icons.info_outline_rounded, size: 25), color: iconColor),
                          IconButton(onPressed: () {}, icon: Icon(Icons.subtitles, size: 25), color: iconColor),
                          IconButton(onPressed: () {}, icon: Icon(Icons.playlist_add, size: 25), color: iconColor),
                          IconButton(onPressed: () {}, icon: Icon(Icons.share_rounded, size: 25), color: iconColor),
                        ],
                      ),
                    ),

                    // Slider & Duration - Rebuilds frequently (optimized)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: BlocBuilder<PlayerBloc, PlayerState>(
                        buildWhen: (previous, current) => previous.position != current.position || previous.duration != current.duration,
                        builder: (context, state) {
                          final duration = state.duration;
                          final position = state.position;

                          // 1. Calculate effective values (considering drag state)
                          double sliderValue = _isDragging ? _dragValue : position.inMilliseconds.toDouble();
                          double maxDuration = duration.inMilliseconds.toDouble();

                          // Ensure slider doesn't crash on edge cases
                          if (maxDuration <= 0) maxDuration = 1.0;
                          sliderValue = sliderValue.clamp(0.0, maxDuration);

                          // 2. Calculate what to show on the left label
                          final Duration currentDisplayTime = Duration(milliseconds: sliderValue.toInt());
                          final Duration remainingTime = duration - currentDisplayTime;

                          return Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: isDarkTheme ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary,
                                  inactiveTrackColor: isDarkTheme ? Theme.of(context).colorScheme.inverseSurface.withAlpha(76) : Theme.of(context).colorScheme.inversePrimary,
                                  thumbColor: isDarkTheme ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary,
                                  trackHeight: 4.0,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0, elevation: 0),
                                ),
                                child: Slider(
                                  value: sliderValue,
                                  min: 0.0,
                                  max: maxDuration,
                                  onChangeStart: (value) => setState(() {
                                    _isDragging = true;
                                    _dragValue = value;
                                  }),
                                  onChanged: (value) => setState(() => _dragValue = value),
                                  onChangeEnd: (value) {
                                    context.read<PlayerBloc>().add(SeekEvent(Duration(milliseconds: value.toInt())));
                                    setState(() => _isDragging = false);
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 23),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Left Side: Toggles between Position and Remaining
                                    InkWell(
                                      onTap: () => setState(() => _showRemaining = !_showRemaining),
                                      child: Text(
                                        _showRemaining ? "-${_formatDuration(remainingTime)}" : _formatDuration(currentDisplayTime),
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.secondary,
                                          fontSize: 13,
                                          fontFeatures: const [FontFeature.tabularFigures()], // Prevents text jumping
                                        ),
                                      ),
                                    ),
                                    // Right Side: Always Total Duration
                                    Text(
                                      _formatDuration(duration),
                                      style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 13, fontFeatures: const [FontFeature.tabularFigures()]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
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
                        IconButton(
                          onPressed: () {
                            final position = context.read<PlayerBloc>().state.position;
                            position.inSeconds > 10 ? context.read<PlayerBloc>().add(const SeekEvent(Duration.zero)) : context.read<PlayerBloc>().add(SkipPreviousEvent());
                          },
                          icon: const Icon(Icons.skip_previous_rounded, size: 40),
                          color: iconColor,
                        ),

                        // Fast seek backward for 5 seconds
                        IconButton(
                          onPressed: () {
                            final position = context.read<PlayerBloc>().state.position;
                            context.read<PlayerBloc>().add(SeekEvent(position.inSeconds < 5 ? Duration.zero : position - const Duration(seconds: 5)));
                          },
                          icon: const Icon(Icons.fast_rewind_rounded, size: 30),
                          color: Theme.of(context).colorScheme.secondary,
                        ),

                        // Play / Pause - Only rebuilds when isPlaying changes
                        BlocSelector<PlayerBloc, PlayerState, bool>(
                          selector: (state) => state.isPlaying,
                          builder: (context, isPlaying) {
                            return IconButton.filled(
                              style: IconButton.styleFrom(backgroundColor: isDarkTheme ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary, foregroundColor: isDarkTheme ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onPrimary),
                              onPressed: () {
                                context.read<PlayerBloc>().add(PlayPauseEvent());
                              },
                              iconSize: 40,
                              icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                            );
                          },
                        ),

                        // Fast seek forward for 5 seconds or skip to next if near the end
                        IconButton(
                          onPressed: () {
                            final state = context.read<PlayerBloc>().state;
                            final remaining = state.duration - state.position;
                            (remaining.inSeconds < 5) ? context.read<PlayerBloc>().add(SkipNextEvent()) : context.read<PlayerBloc>().add(SeekEvent(state.position + const Duration(seconds: 5)));
                          },
                          icon: const Icon(Icons.fast_forward_rounded, size: 30),
                          color: Theme.of(context).colorScheme.secondary,
                        ),

                        // Skip Next
                        IconButton(onPressed: () => context.read<PlayerBloc>().add(SkipNextEvent()), icon: const Icon(Icons.skip_next_rounded, size: 40), color: iconColor),

                          // Mode Button
                          Tooltip(
                            message: _modeToolTip[_playModeController],
                            child: IconButton(onPressed: _changePlayMode, icon: Icon(_playModeIcon, size: 28), color: Theme.of(context).colorScheme.secondary, padding: const EdgeInsets.all(16)),
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
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, bool isDarkTheme) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.43,
      width: 350,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        boxShadow: [BoxShadow(color: isDarkTheme ? _bgColors[0].withAlpha(100) : _bgColors[0].withAlpha(50), blurRadius: 30, spreadRadius: 5)],
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
        boxShadow: isCurrent ? [BoxShadow(color: isDarkTheme ? _bgColors[0].withAlpha(100) : _bgColors[0].withAlpha(50), blurRadius: 30, spreadRadius: 5)] : null,
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
