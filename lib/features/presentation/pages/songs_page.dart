import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:get_it/get_it.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  final OnAudioQuery _audioQuery = GetIt.I<OnAudioQuery>();
  final AudioPlayer _audioPlayer = GetIt.I<AudioPlayer>();

  Future<void> _playSong(SongModel song) async {
    try {
      Uri audioUri = Uri.parse("content://media/external/audio/media/${song.id}");

      await _audioPlayer.setAudioSource(AudioSource.uri(audioUri));
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Error Playing Song: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsGeometry.symmetric(horizontal: 10),
          sliver: FutureBuilder<List<SongModel>>(
            future: _audioQuery.querySongs(
              sortType: SongSortType.DATE_ADDED,
              orderType: OrderType.DESC_OR_GREATER,
              uriType: UriType.EXTERNAL, // Look For External Storage
              ignoreCase: true, // Ignore Letter Cases
            ),
            builder: (context, item) {
              // Loading
              if (item.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(child: const Center(child: CircularProgressIndicator()));
              }

              // If There's No Music
              if (item.data == null || item.data!.isEmpty) {
                return SliverToBoxAdapter(child: const Center(child: Text("No songs found!")));
              }

              // Show Music
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  // Get Song Info
                  SongModel song = item.data![index];

                  return ListTile(
                    title: Text(song.title, style: Theme.of(context).textTheme.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(song.artist ?? "Unknown Artist", style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    // Song Cover (ArtWork)
                    leading: QueryArtworkWidget(id: song.id, type: ArtworkType.AUDIO, nullArtworkWidget: const Icon(Icons.music_note)),
                    onTap: () => _playSong(song),
                  );
                }, childCount: item.data!.length),
              );
            },
          ),
        ),
      ],
    );
  }
}