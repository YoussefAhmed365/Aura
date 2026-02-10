import 'package:aura/core/di/injection.dart';
import 'package:aura/features/music_player/domain/repositories/audio_repository.dart';
import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongListByEntity extends StatelessWidget {
  final int id;
  final String title;
  final bool isArtist; // true if artist, false if album

  const SongListByEntity({super.key, required this.id, required this.title, required this.isArtist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FutureBuilder<List<SongModel>>(
          // You'll need to implement this method in your repository
          future: isArtist ? getIt<AudioRepository>().getSongsByArtist(id) : getIt<AudioRepository>().getSongsByAlbum(id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const Center(child: Text("Error loading songs"));
            }
            final songs = snapshot.data!;
            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
              },
            );
          },
        ),
      ),
    );
  }
}
