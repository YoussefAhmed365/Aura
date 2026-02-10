import 'package:on_audio_query/on_audio_query.dart';

abstract class AudioRepository {
  // Get Music
  Future<List<SongModel>> getSongs();

  // Get Albums
  Future<List<AlbumModel>> getAlbums();

  // Get Artists
  Future<List<ArtistModel>> getArtists();

  // Get Songs By Artist
  Future<List<SongModel>> getSongsByArtist(int artistId);

  // Get Songs By Album
  Future<List<SongModel>> getSongsByAlbum(int albumId);
}
