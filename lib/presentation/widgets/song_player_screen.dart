import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import the package

class SongPlayerScreen extends StatefulWidget {
  const SongPlayerScreen({super.key});

  @override
  State<SongPlayerScreen> createState() => _SongPlayerScreenState();
}

class _SongPlayerScreenState extends State<SongPlayerScreen> {
  bool _playController = false;
  double _currentSliderValue = 30;
  int _playModeController = 0;
  IconData _playModeIcon = Icons.repeat_rounded;
  final List<String> _modeToolTip = ['Shuffle Mode Is Off', 'Shuffle Mode Is On'];

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

    // CALL THE NATIVE SYSTEM TOAST
    _showSystemToast(_modeToolTip[_playModeController]);
  }

  // --- Native System Toast Implementation ---
  void _showSystemToast(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Color(0xCC000000), textColor: Colors.white, fontSize: 14.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2E1C4E), Colors.black]),
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
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 35),
                        ),
                        Text("Now Playing", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70, letterSpacing: 1.5)),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.more_vert, color: Colors.white),
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
                        image: const DecorationImage(image: AssetImage("assets/images/cover-4.jpg"), fit: BoxFit.cover),
                        boxShadow: [BoxShadow(color: Colors.purple.withAlpha(102), blurRadius: 30, spreadRadius: 5)],
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Song Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        Text(
                          "Midnight City",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text("M83", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white60)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Function Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_outline_rounded),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.info_outline_rounded),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.subtitles),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.playlist_add),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share_rounded),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      InkWell(
                        onTap: () {},
                        onLongPress: () {},
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.navigate_next, size: 28, color: Theme.of(context).colorScheme.onSurface),
                              const SizedBox(width: 3),
                              Container(height: 25, width: 1, color: Theme.of(context).colorScheme.outline),
                              const SizedBox(width: 3),
                              Icon(Icons.queue_music_rounded, size: 28, color: Theme.of(context).colorScheme.onSurface),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Slider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(
                            context,
                          ).copyWith(activeTrackColor: Colors.white, inactiveTrackColor: Colors.white.withAlpha(77), thumbColor: Colors.white, trackShape: const RoundedRectSliderTrackShape(), trackHeight: 4.0, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0, elevation: 0), overlayColor: Colors.white.withAlpha(26), overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0)),
                          child: Slider(
                            value: _currentSliderValue,
                            max: 100,
                            onChanged: (double value) {
                              setState(() {
                                _currentSliderValue = value;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("1:32", style: TextStyle(color: Colors.white54, fontSize: 12)),
                              const Text("4:05", style: TextStyle(color: Colors.white54, fontSize: 12)),
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
                        onPressed: () {},
                        icon: const Icon(Icons.equalizer_rounded, size: 28),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.skip_previous_rounded, size: 40),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        onPressed: () {
                          setState(() {
                            _playController = !_playController;
                          });
                        },
                        iconSize: 40,
                        icon: Icon(_playController ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.skip_next_rounded, size: 40),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),

                      // THE MODE BUTTON
                      Tooltip(
                        message: _modeToolTip[_playModeController],
                        child: IconButton(
                          onPressed: _changePlayMode,
                          icon: Icon(_playModeIcon, size: 28),
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          padding: const EdgeInsets.all(16),
                        ),
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
  }
}
