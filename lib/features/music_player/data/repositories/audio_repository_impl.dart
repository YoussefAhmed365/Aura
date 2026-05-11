import 'package:aura/features/music_player/domain/repositories/audio_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton(as: AudioRepository)
class AudioRepositoryImpl implements AudioRepository {
  final OnAudioQuery _audioQuery;
  final SharedPreferences _prefs;

  AudioRepositoryImpl(this._audioQuery, this._prefs);

  static const String _favoritesKey = 'favorite_songs';

  // مفاتيح تخزين الجلسة والقوائم
  static const String _queuesKey = 'saved_custom_queues';
  static const String _lastActiveQueueIdKey = 'last_active_queue_id';
  static const String _lastIndexKey = 'last_song_index';
  static const String _lastPositionKey = 'last_position';

  @override
  Future<List<SongModel>> getSongs() async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      permissionStatus = await _audioQuery.permissionsRequest();
    }

    if (!permissionStatus) {
      return [];
    }

    return await _audioQuery.querySongs(sortType: SongSortType.DATE_ADDED, orderType: OrderType.DESC_OR_GREATER, uriType: UriType.EXTERNAL, ignoreCase: true);
  }

  @override
  Future<List<SongModel>> getSongsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    // Get all songs and filter them by IDs
    // Note: on_audio_query doesn't have a direct 'queryByIds' for multiple IDs at once efficiently
    // beyond basic querying. For better performance in large libraries, we fetch all and filter.
    final allSongs = await getSongs();
    final idSet = ids.toSet();
    return allSongs.where((song) => idSet.contains(song.id)).toList();
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

  @override
  Future<List<int>> getAllFavoriteSongsIds() async {
    final List<String> stringIds = _prefs.getStringList(_favoritesKey) ?? [];
    return stringIds.map((id) => int.parse(id)).toList();
  }

  @override
  Future<bool> addSongToFavorites(int songId) async {
    final List<String> stringIds = _prefs.getStringList(_favoritesKey) ?? [];
    final String idStr = songId.toString();

    if (!stringIds.contains(idStr)) {
      stringIds.add(idStr);
      return await _prefs.setStringList(_favoritesKey, stringIds);
    }
    return false;
  }

  @override
  Future<bool> removeSongFromFavorites(int songId) async {
    final List<String> stringIds = _prefs.getStringList(_favoritesKey) ?? [];
    final String idStr = songId.toString();

    if (stringIds.contains(idStr)) {
      stringIds.remove(idStr);
      return await _prefs.setStringList(_favoritesKey, stringIds);
    }
    return false;
  }

  @override
  Future<bool> isSongFavorite(int songId) async {
    final List<String> stringIds = _prefs.getStringList(_favoritesKey) ?? [];
    return stringIds.contains(songId.toString());
  }

  // --- تنفيذ دوال الجلسة والقوائم المخصصة ---

  @override
  Future<String?> getSavedQueuesJson() async {
    return _prefs.getString(_queuesKey);
  }

  @override
  Future<bool> saveQueuesJson(String json) async {
    return await _prefs.setString(_queuesKey, json);
  }

  @override
  Future<void> saveCurrentSession({String? activeQueueId, required int currentIndex, required int positionMs}) async {
    if (activeQueueId != null) {
      await _prefs.setString(_lastActiveQueueIdKey, activeQueueId);
    }
    await _prefs.setInt(_lastIndexKey, currentIndex);
    await _prefs.setInt(_lastPositionKey, positionMs);
  }

  @override
  Future<Map<String, dynamic>> getLastSession() async {
    return {
      'activeQueueId': _prefs.getString(_lastActiveQueueIdKey),
      'currentIndex': _prefs.getInt(_lastIndexKey),
      'positionMs': _prefs.getInt(_lastPositionKey),
    };
  }
}