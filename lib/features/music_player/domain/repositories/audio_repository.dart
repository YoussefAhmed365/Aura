import 'package:on_audio_query/on_audio_query.dart';

abstract class AudioRepository {
  // Get Music
  Future<List<SongModel>> getSongs();
  // Get Folders
  Future<List<AlbumModel>> getAlbums();
}