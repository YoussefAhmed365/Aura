import 'dart:convert';
import 'package:aura/features/music_player/domain/repositories/audio_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audio_service/audio_service.dart';
import '../../domain/models/custom_queue.dart';

@LazySingleton(as: AudioRepository)
class AudioRepositoryImpl implements AudioRepository {
  final OnAudioQuery _audioQuery;
  final SharedPreferences _prefs;
  final Box<CustomQueue> _queuesBox;
  final Box<dynamic> _sessionBox;
  final Box<String> _lyricsBox;

  AudioRepositoryImpl(
    this._audioQuery,
    this._prefs,
    @Named('customQueuesBox') this._queuesBox,
    @Named('sessionBox') this._sessionBox,
    @Named('lyricsBox') this._lyricsBox,
  ) {
    _migrateOldDataIfNeeded();
  }

  static const String _favoritesKey = 'favorite_songs';

  void _migrateOldDataIfNeeded() {
    // Migrate Queues
    final oldQueues = _prefs.getString('saved_custom_queues');
    if (oldQueues != null) {
      try {
        final List<dynamic> decoded = jsonDecode(oldQueues);
        for (var q in decoded) {
          final items = (q['items'] as List)
              .map((item) => MediaItem(
                    id: item['id'],
                    album: item['album'],
                    title: item['title'],
                    artist: item['artist'],
                    duration: item['duration'] != null ? Duration(milliseconds: item['duration']) : null,
                    artUri: item['artUri'] != null ? Uri.parse(item['artUri']) : null,
                    extras: item['extras'] != null ? Map<String, dynamic>.from(item['extras']) : null,
                  ))
              .toList();
          final customQueue = CustomQueue(
            id: q['id'],
            name: q['name'],
            items: items,
          );
          _queuesBox.put(customQueue.id, customQueue);
        }
        _prefs.remove('saved_custom_queues');
      } catch (_) {}
    }

    // Migrate Session
    final oldActiveQueueId = _prefs.getString('last_active_queue_id');
    final oldIndex = _prefs.getInt('last_song_index');
    final oldPosition = _prefs.getInt('last_position');

    if (oldActiveQueueId != null) {
      _sessionBox.put('activeQueueId', oldActiveQueueId);
      _prefs.remove('last_active_queue_id');
    }
    if (oldIndex != null) {
      _sessionBox.put('currentIndex', oldIndex);
      _prefs.remove('last_song_index');
    }
    if (oldPosition != null) {
      _sessionBox.put('positionMs', oldPosition);
      _prefs.remove('last_position');
    }
  }

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

  // --- تنفيذ دوال الجلسة والقوائم المخصصة بـ Hive ---

  @override
  Future<List<CustomQueue>> getSavedQueues() async {
    return _queuesBox.values.toList();
  }

  @override
  Future<void> saveQueue(CustomQueue queue) async {
    await _queuesBox.put(queue.id, queue);
  }

  @override
  Future<void> deleteQueue(String queueId) async {
    await _queuesBox.delete(queueId);
  }

  @override
  Future<void> saveCurrentSession({String? activeQueueId, required int currentIndex, required int positionMs}) async {
    if (activeQueueId != null) {
      await _sessionBox.put('activeQueueId', activeQueueId);
    }
    await _sessionBox.put('currentIndex', currentIndex);
    await _sessionBox.put('positionMs', positionMs);
  }

  @override
  Future<Map<String, dynamic>> getLastSession() async {
    return {
      'activeQueueId': _sessionBox.get('activeQueueId'),
      'currentIndex': _sessionBox.get('currentIndex'),
      'positionMs': _sessionBox.get('positionMs'),
    };
  }

  // كلمات الأغاني (Lyrics)

  @override
  Future<String?> getCachedLyrics(String songId) async {
    return _lyricsBox.get(songId);
  }

  @override
  Future<void> cacheLyrics(String songId, String lyrics) async {
    await _lyricsBox.put(songId, lyrics);
  }
}