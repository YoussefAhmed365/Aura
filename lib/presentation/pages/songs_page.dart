import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsGeometry.symmetric(horizontal: 10),
          sliver: FutureBuilder<List<SongModel>>(
            future: _audioQuery.querySongs(
              sortType: null, // No Sort
              orderType: OrderType.ASC_OR_SMALLER, // Ascindent
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
                    onTap: () {
                      print("Playing ${song.title}");
                    },
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
