import 'package:aura/core/di/injection.dart';
import 'package:aura/features/music_player/domain/repositories/audio_repository.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:aura/features/songs/presentation/song_list_by_entity.dart';
import 'package:aura/core/widgets/sliver_list_tile.dart';

class Albums extends StatefulWidget {
  const Albums({super.key});

  @override
  State<Albums> createState() => _AlbumsState();
}

class _AlbumsState extends State<Albums> {
  late Future<List<AlbumModel>> _albumsFuture;

  @override
  void initState() {
    super.initState();
    _albumsFuture = getIt<AudioRepository>().getAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return SliverListTile<AlbumModel>(
      future: _albumsFuture,
      artworkType: ArtworkType.ALBUM,
      title: (album) => album.album,
      subtitle: (album) => "${album.numOfSongs} songs",
      id: (album) => album.id,
      onTap: (list, index) {
        final album = list[index];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SongListByEntity(id: album.id, title: album.album, isArtist: false),
          ),
        );
      },
    );
  }
}
