import 'package:aura/core/di/injection.dart';
import 'package:aura/core/widgets/sliver_list_tile.dart';
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
    return SliverListTile<SongModel>(
      future: _songsFuture,
      artworkType: ArtworkType.AUDIO,
      title: (song) => song.title,
      subtitle: (song) => "${song.artist ?? "Unknown"} • ${song.album ?? "Unknown"}",
      id: (song) => song.id,
      onTap: (list, index) {
        context.read<PlayerBloc>().add(PlayAllEvent(songs: list, index: index));
      },
    );
  }
}
