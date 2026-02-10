import 'package:aura/core/di/injection.dart';
import 'package:aura/features/music_player/domain/repositories/audio_repository.dart';
import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Songs extends StatefulWidget {
  const Songs({super.key});

  @override
  State<Songs> createState() => _SongsState();
}

class _SongsState extends State<Songs> {
  late Future<List<SongModel>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _songsFuture = getIt<AudioRepository>().getSongs();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      sliver: FutureBuilder<List<SongModel>>(
        future: _songsFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator()));
          }

          // Error
          if (snapshot.hasError) {
            return SliverFillRemaining(hasScrollBody: false, child: Center(child: Text("Error: ${snapshot.error}")));
          }

          // Empty
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text("No songs found!")));
          }

          // List Items
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              SongModel song = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: InkWell(
                  onTap: () {
                    context.read<PlayerBloc>().add(PlayAllEvent(songs: snapshot.data!, index: index));
                  },
                  splashColor: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    children: [
                      // Rounded Artwork
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: QueryArtworkWidget(
                          id: song.id,
                          type: ArtworkType.AUDIO,
                          artworkWidth: 60,
                          artworkHeight: 60,
                          keepOldArtwork: true,
                          nullArtworkWidget: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(color: Colors.grey.withAlpha(26), borderRadius: BorderRadius.circular(15)),
                            child: const Icon(Icons.music_note, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Song Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${song.artist ?? "Unknown"} • ${song.album ?? "Unknown"}",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // More Options Icon
                      IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.grey),
                        onPressed: () {
                          // Show options menu
                        },
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: snapshot.data!.length),
          );
        },
      ),
    );
  }
}
