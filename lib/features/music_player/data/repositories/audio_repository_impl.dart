import 'package:aura/features/music_player/domain/repositories/audio_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AudioRepository)
class AudioRepositoryImpl implements AudioRepository {
  final OnAudioQuery _audioQuery;

  // "OnAudioQuery" Injected Automatically (Registered Before in "register_module.dart")
  AudioRepositoryImpl(this._audioQuery);

  // Get Permissions
  @override
  Future<List<SongModel>> getSongs() async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      await _audioQuery.permissionsRequest();
    }

    // Get Songs
    return await _audioQuery.querySongs(
      sortType: SongSortType.DATE_ADDED,
      orderType: OrderType.DESC_OR_GREATER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
  }

  @override
  Future<List<AlbumModel>> getAlbums() async {
    return await _audioQuery.queryAlbums();
  }
}