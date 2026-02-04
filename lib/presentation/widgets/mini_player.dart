import 'package:flutter/material.dart';
import 'song_player_screen.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> with SingleTickerProviderStateMixin {
  bool _playController = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  void _openMusicPlayer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // يسمح للمشغل بأخذ كامل الشاشة
      useRootNavigator: true, // يغطي الـ BottomNavigationBar إذا وجد
      backgroundColor: Colors.transparent, // لجعل الحواف شفافة
      builder: (context) => const SongPlayerScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openMusicPlayer,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(color: Color(0xFF231344), borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Row(
              children: [
                RotationTransition(
                  turns: _animationController,
                  // أضفت Hero هنا لربط صورة المشغل المصغر بالمشغل الكبير
                  child: Hero(
                    tag: 'current_song_image', // نفس التاغ في SongPlayerPage
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(image: AssetImage("assets/images/cover-4.jpg"), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text("name", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
            Row(
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.skip_previous, size: 35)),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _playController = !_playController;
                      if (_playController) {
                        _animationController.repeat();
                      } else {
                        _animationController.stop();
                      }
                    });
                  },
                  icon: Icon(_playController ? Icons.pause_circle : Icons.play_circle, size: 35),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.skip_next, size: 35)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
