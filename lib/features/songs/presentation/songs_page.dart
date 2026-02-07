import 'package:aura/core/di/injection.dart';
import 'package:aura/features/music_player/domain/repositories/audio_repository.dart';
import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsGeometry.symmetric(horizontal: 10),
          sliver: FutureBuilder<List<SongModel>>(
            future: getIt<AudioRepository>().getSongs(),
            builder: (context, snapshot) {
              // Loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              // Has Error
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(child: Text("Error: ${snapshot.error}")),
                  ),
                );
              }

              // If There's No Music
              if (snapshot.data == null || snapshot.data!.isEmpty) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: const Center(child: Text("No songs found!")),
                  ),
                );
              }

              // Show Music
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  // Get Song Info
                  SongModel song = snapshot.data![index];

                  return ListTile(
                    title: Text(song.title, style: Theme.of(context).textTheme.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(song.artist ?? "Unknown Artist", style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    // Song Cover (ArtWork)
                    leading: QueryArtworkWidget(id: song.id, type: ArtworkType.AUDIO, nullArtworkWidget: const Icon(Icons.music_note)),
                    onTap: () {
                      context.read<PlayerBloc>().add(
                        PlayAllEvent(songs: snapshot.data!, index: index)
                      );
                    },
                  );
                }, childCount: snapshot.data!.length),
              );
            },
          ),
        ),
      ],
    );
  }
}
