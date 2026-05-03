import 'package:aura/core/di/injection.dart';
import 'package:aura/features/music_player/domain/repositories/audio_repository.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:aura/features/songs/presentation/song_list_by_entity.dart';
import 'package:aura/core/widgets/sliver_list_tile.dart';

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
    return SliverListTile<ArtistModel>(
      future: _artistsFuture,
      artworkType: ArtworkType.ARTIST,
      title: (artist) => artist.artist,
      subtitle: (artist) => "${artist.numberOfTracks} songs",
      id: (artist) => artist.id,
      onTap: (list, index) {
        final artist = list[index];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SongListByEntity(id: artist.id, title: artist.artist, isArtist: true),
          ),
        );
      },
    );
  }
}
