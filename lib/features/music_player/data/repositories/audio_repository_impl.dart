import 'package:aura/features/music_player/domain/repositories/audio_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:on_audio_query/on_audio_query.dart';

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
      permissionStatus = await _audioQuery.permissionsRequest();
    }

    if (!permissionStatus) {
      return [];
    }

    // Get Songs
    return await _audioQuery.querySongs(sortType: SongSortType.DATE_ADDED, orderType: OrderType.DESC_OR_GREATER, uriType: UriType.EXTERNAL, ignoreCase: true);
  }

  @override
  Future<List<AlbumModel>> getAlbums() async {
    return await _audioQuery.queryAlbums();
  }

  @override
  Future<List<ArtistModel>> getArtists() async {
    return await _audioQuery.queryArtists();
  }

  @override
  Future<List<SongModel>> getSongsByAlbum(int albumId) async {
    return await _audioQuery.queryAudiosFrom(AudiosFromType.ALBUM_ID, albumId, sortType: SongSortType.DATE_ADDED);
  }

  @override
  Future<List<SongModel>> getSongsByArtist(int artistId) async {
    return await _audioQuery.queryAudiosFrom(AudiosFromType.ARTIST_ID, artistId, sortType: SongSortType.DATE_ADDED);
  }

  @override
  Future<List<PlaylistModel>> getPlaylists() async {
    return await _audioQuery.queryPlaylists();
  }

  @override
  Future<List<SongModel>> getSongsByPlaylist(int playlistId) async {
    return await _audioQuery.queryAudiosFrom(AudiosFromType.PLAYLIST, playlistId, sortType: SongSortType.DATE_ADDED);
  }

  @override
  Future<bool> createPlaylist(String name) async {
    return await _audioQuery.createPlaylist(name);
  }

  @override
  Future<bool> removePlaylist(int playlistId) async {
    return await _audioQuery.removePlaylist(playlistId);
  }
}
