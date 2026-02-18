import 'package:aura/core/di/injection.dart';
import 'package:aura/features/music_player/domain/repositories/audio_repository.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:aura/features/songs/presentation/song_list_by_entity.dart';

class Artists extends StatefulWidget {
  const Artists({super.key});

  @override
  State<Artists> createState() => _ArtistsState();
}

class _ArtistsState extends State<Artists> {
  late Future<List<ArtistModel>> _artistsFuture;

  @override
  void initState() {
    super.initState();
    _artistsFuture = getIt<AudioRepository>().getArtists();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10, bottom: 80),
      sliver: FutureBuilder(
        future: _artistsFuture,
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
            return const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text("No artists found!")));
          }

          // List Items
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              ArtistModel artist = snapshot.data![index];
              return Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongListByEntity(
                        id: artist.id,
                        title: artist.artist,
                        isArtist: true,
                      ),
                    ),
                  );
                },
                splashColor: Theme.of(context).colorScheme.surface,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: QueryArtworkWidget(
                        id: artist.id,
                        type: ArtworkType.ARTIST,
                        artworkWidth: 60,
                        artworkHeight: 60,
                        keepOldArtwork: true,
                        nullArtworkWidget: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(color: Colors.grey.withAlpha(26), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // Artist Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            artist.artist,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${artist.numberOfTracks} songs",
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
              ));
            }, childCount: snapshot.data!.length),
          );
        },
      ),
    );
  }
}
