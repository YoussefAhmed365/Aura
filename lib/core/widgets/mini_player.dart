import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../features/music_player/presentation/song_player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم BlocBuilder للاستماع للتغيرات
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        // إذا لم تكن هناك أغنية مختارة، نخفي المشغل
        if (state.currentSong == null) return const SizedBox.shrink();

        final song = state.currentSong!;

        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const SongPlayerScreen(),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(40), topLeft: Radius.circular(40)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Expanded لتجنب الخطأ إذا كان الاسم طويلاً
                  child: Row(
                    children: [
                      // صورة الأغنية
                      Hero(
                        tag: 'current_song_image',
                        child: QueryArtworkWidget(
                          id: int.parse(song.id), // نحول الـ ID لـ int
                          type: ArtworkType.AUDIO,
                          artworkHeight: 50,
                          artworkWidth: 50,
                          artworkFit: BoxFit.cover,
                          nullArtworkWidget: Container(
                            width: 50, height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: const Icon(Icons.music_note),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // اسم الأغنية
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              song.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              song.artist ?? "Unknown",
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // أزرار التحكم
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.read<PlayerBloc>().add(SkipPreviousEvent()),
                      icon: const Icon(Icons.skip_previous, size: 30),
                    ),
                    IconButton(
                      onPressed: () {
                        // إرسال حدث التشغيل/الإيقاف
                        context.read<PlayerBloc>().add(PlayPauseEvent());
                      },
                      // تغيير الأيقونة حسب الحالة
                      icon: Icon(
                        state.isPlaying ? Icons.pause_circle : Icons.play_circle,
                        size: 35,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.read<PlayerBloc>().add(SkipNextEvent()),
                      icon: const Icon(Icons.skip_next, size: 30),
                    ),
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