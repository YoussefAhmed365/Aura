import 'package:on_audio_query/on_audio_query.dart';
import '../models/custom_queue.dart';

abstract class AudioRepository {
  // Get Music
  Future<List<SongModel>> getSongs();

  // Get A List Of Songs By IDs
  Future<List<SongModel>> getSongsByIds(List<int> ids);

  // Get Albums
  Future<List<AlbumModel>> getAlbums();

  // Get Artists
  Future<List<ArtistModel>> getArtists();

  // Get Songs By Artist
  Future<List<SongModel>> getSongsByArtist(int artistId);

  // Get Songs By Album
  Future<List<SongModel>> getSongsByAlbum(int albumId);

  // Get Playlists
  Future<List<PlaylistModel>> getPlaylists();

  // Get Songs By Playlist
  Future<List<SongModel>> getSongsByPlaylist(int playlistId);

  // Create Playlist
  Future<bool> createPlaylist(String name);

  // Remove Playlist
  Future<bool> removePlaylist(int playlistId);

  // Get All Favorites
  Future<List<int>> getAllFavoriteSongsIds();

  // Add To Favorite
  Future<bool> addSongToFavorites(int songId);

  // Remove From Favorite
  Future<bool> removeSongFromFavorites(int songId);

  // Check if song is favorite
  Future<bool> isSongFavorite(int songId);

  // --- إدارة الجلسة والقوائم المخصصة ---

  // جلب وحفظ القوائم المخصصة باستخدام Hive
  Future<List<CustomQueue>> getSavedQueues();
  Future<void> saveQueue(CustomQueue queue);
  Future<void> deleteQueue(String queueId);

  // حفظ الجلسة الحالية (موضع الأغنية، الفهرس، ومعرف القائمة)
  Future<void> saveCurrentSession({String? activeQueueId, required int currentIndex, required int positionMs});

  // استرجاع تفاصيل الجلسة الأخيرة
  Future<Map<String, dynamic>> getLastSession();

  // كلمات الأغاني (Lyrics)
  Future<String?> getCachedLyrics(String songId);
  Future<void> cacheLyrics(String songId, String lyrics);
}