import 'package:aura/features/music_player/data/repositories/audio_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockOnAudioQuery extends Mock implements OnAudioQuery {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late AudioRepositoryImpl repository;
  late MockOnAudioQuery mockOnAudioQuery;
  late MockSharedPreferences mockSharedPreferences;

  setUpAll(() {
    registerFallbackValue(AudiosFromType.ALBUM_ID);
    registerFallbackValue(SongSortType.TITLE);
    registerFallbackValue(OrderType.ASC_OR_SMALLER);
    registerFallbackValue(UriType.EXTERNAL);
  });

  setUp(() {
    mockOnAudioQuery = MockOnAudioQuery();
    mockSharedPreferences = MockSharedPreferences();
    repository = AudioRepositoryImpl(mockOnAudioQuery, mockSharedPreferences);
  });

  group('AudioRepositoryImpl', () {
    group('getSongs', () {
      test('should return list of songs when permission is granted initially', () async {
        // Arrange
        when(() => mockOnAudioQuery.permissionsStatus()).thenAnswer((_) async => true);
        final expectedSongs = <SongModel>[];
        when(() => mockOnAudioQuery.querySongs(
              sortType: any(named: 'sortType'),
              orderType: any(named: 'orderType'),
              uriType: any(named: 'uriType'),
              ignoreCase: any(named: 'ignoreCase'),
            )).thenAnswer((_) async => expectedSongs);

        // Act
        final result = await repository.getSongs();

        // Assert
        expect(result, expectedSongs);
        verify(() => mockOnAudioQuery.permissionsStatus()).called(1);
        verifyNever(() => mockOnAudioQuery.permissionsRequest());
        verify(() => mockOnAudioQuery.querySongs(
              sortType: SongSortType.DATE_ADDED,
              orderType: OrderType.DESC_OR_GREATER,
              uriType: UriType.EXTERNAL,
              ignoreCase: true,
            )).called(1);
      });

      test('should request permission and return songs when permission is initially denied but then granted', () async {
        // Arrange
        when(() => mockOnAudioQuery.permissionsStatus()).thenAnswer((_) async => false);
        when(() => mockOnAudioQuery.permissionsRequest()).thenAnswer((_) async => true);
        final expectedSongs = <SongModel>[];
        when(() => mockOnAudioQuery.querySongs(
              sortType: any(named: 'sortType'),
              orderType: any(named: 'orderType'),
              uriType: any(named: 'uriType'),
              ignoreCase: any(named: 'ignoreCase'),
            )).thenAnswer((_) async => expectedSongs);

        // Act
        final result = await repository.getSongs();

        // Assert
        expect(result, expectedSongs);
        verify(() => mockOnAudioQuery.permissionsStatus()).called(1);
        verify(() => mockOnAudioQuery.permissionsRequest()).called(1);
        verify(() => mockOnAudioQuery.querySongs(
              sortType: SongSortType.DATE_ADDED,
              orderType: OrderType.DESC_OR_GREATER,
              uriType: UriType.EXTERNAL,
              ignoreCase: true,
            )).called(1);
      });

      test('should return empty list when permission is denied and request is denied', () async {
        // Arrange
        when(() => mockOnAudioQuery.permissionsStatus()).thenAnswer((_) async => false);
        when(() => mockOnAudioQuery.permissionsRequest()).thenAnswer((_) async => false);

        // Act
        final result = await repository.getSongs();

        // Assert
        expect(result, isEmpty);
        verify(() => mockOnAudioQuery.permissionsStatus()).called(1);
        verify(() => mockOnAudioQuery.permissionsRequest()).called(1);
        verifyNever(() => mockOnAudioQuery.querySongs(
              sortType: any(named: 'sortType'),
              orderType: any(named: 'orderType'),
              uriType: any(named: 'uriType'),
              ignoreCase: any(named: 'ignoreCase'),
            ));
      });
    });

    group('getAlbums', () {
      test('should return list of albums when queryAlbums is called', () async {
        // Arrange
        final expectedAlbums = <AlbumModel>[];
        when(() => mockOnAudioQuery.queryAlbums()).thenAnswer((_) async => expectedAlbums);

        // Act
        final result = await repository.getAlbums();

        // Assert
        expect(result, expectedAlbums);
        verify(() => mockOnAudioQuery.queryAlbums()).called(1);
      });
    });

    group('getArtists', () {
      test('should return list of artists when queryArtists is called', () async {
        // Arrange
        final expectedArtists = <ArtistModel>[];
        when(() => mockOnAudioQuery.queryArtists()).thenAnswer((_) async => expectedArtists);

        // Act
        final result = await repository.getArtists();

        // Assert
        expect(result, expectedArtists);
        verify(() => mockOnAudioQuery.queryArtists()).called(1);
      });
    });

    group('getSongsByAlbum', () {
      test('should return list of songs for a given albumId', () async {
        // Arrange
        const albumId = 123;
        final expectedSongs = <SongModel>[];
        when(() => mockOnAudioQuery.queryAudiosFrom(
              any(),
              any(),
              sortType: any(named: 'sortType'),
            )).thenAnswer((_) async => expectedSongs);

        // Act
        final result = await repository.getSongsByAlbum(albumId);

        // Assert
        expect(result, expectedSongs);
        verify(() => mockOnAudioQuery.queryAudiosFrom(
              AudiosFromType.ALBUM_ID,
              albumId,
              sortType: SongSortType.DATE_ADDED,
            )).called(1);
      });
    });

    group('getSongsByArtist', () {
      test('should return list of songs for a given artistId', () async {
        // Arrange
        const artistId = 456;
        final expectedSongs = <SongModel>[];
        when(() => mockOnAudioQuery.queryAudiosFrom(
              any(),
              any(),
              sortType: any(named: 'sortType'),
            )).thenAnswer((_) async => expectedSongs);

        // Act
        final result = await repository.getSongsByArtist(artistId);

        // Assert
        expect(result, expectedSongs);
        verify(() => mockOnAudioQuery.queryAudiosFrom(
              AudiosFromType.ARTIST_ID,
              artistId,
              sortType: SongSortType.DATE_ADDED,
            )).called(1);
      });
    });

    group('getPlaylists', () {
      test('should return list of playlists when queryPlaylists is called', () async {
        // Arrange
        final expectedPlaylists = <PlaylistModel>[];
        when(() => mockOnAudioQuery.queryPlaylists()).thenAnswer((_) async => expectedPlaylists);

        // Act
        final result = await repository.getPlaylists();

        // Assert
        expect(result, expectedPlaylists);
        verify(() => mockOnAudioQuery.queryPlaylists()).called(1);
      });
    });

    group('getSongsByPlaylist', () {
      test('should return list of songs for a given playlistId', () async {
        // Arrange
        const playlistId = 789;
        final expectedSongs = <SongModel>[];
        when(() => mockOnAudioQuery.queryAudiosFrom(
              any(),
              any(),
              sortType: any(named: 'sortType'),
            )).thenAnswer((_) async => expectedSongs);

        // Act
        final result = await repository.getSongsByPlaylist(playlistId);

        // Assert
        expect(result, expectedSongs);
        verify(() => mockOnAudioQuery.queryAudiosFrom(
              AudiosFromType.PLAYLIST,
              playlistId,
              sortType: SongSortType.DATE_ADDED,
            )).called(1);
      });
    });

    group('createPlaylist', () {
      test('should return true when playlist is created successfully', () async {
        // Arrange
        const playlistName = 'My Playlist';
        when(() => mockOnAudioQuery.createPlaylist(any())).thenAnswer((_) async => true);

        // Act
        final result = await repository.createPlaylist(playlistName);

        // Assert
        expect(result, true);
        verify(() => mockOnAudioQuery.createPlaylist(playlistName)).called(1);
      });
    });

    group('removePlaylist', () {
      test('should return true when playlist is removed successfully', () async {
        // Arrange
        const playlistId = 123;
        when(() => mockOnAudioQuery.removePlaylist(any())).thenAnswer((_) async => true);

        // Act
        final result = await repository.removePlaylist(playlistId);

        // Assert
        expect(result, true);
        verify(() => mockOnAudioQuery.removePlaylist(playlistId)).called(1);
      });
    });

    group('Favorites', () {
      const favoritesKey = 'favorite_songs';

      test('getAllFavoriteSongsIds should return list of ids from SharedPreferences', () async {
        // Arrange
        when(() => mockSharedPreferences.getStringList(favoritesKey)).thenReturn(['1', '2', '3']);

        // Act
        final result = await repository.getAllFavoriteSongsIds();

        // Assert
        expect(result, [1, 2, 3]);
        verify(() => mockSharedPreferences.getStringList(favoritesKey)).called(1);
      });

      test('addSongToFavorites should add song id and return true if not present', () async {
        // Arrange
        when(() => mockSharedPreferences.getStringList(favoritesKey)).thenReturn(['1']);
        when(() => mockSharedPreferences.setStringList(any(), any())).thenAnswer((_) async => true);

        // Act
        final result = await repository.addSongToFavorites(2);

        // Assert
        expect(result, true);
        verify(() => mockSharedPreferences.getStringList(favoritesKey)).called(1);
        verify(() => mockSharedPreferences.setStringList(favoritesKey, ['1', '2'])).called(1);
      });

      test('removeSongFromFavorites should remove song id and return true if present', () async {
        // Arrange
        when(() => mockSharedPreferences.getStringList(favoritesKey)).thenReturn(['1', '2']);
        when(() => mockSharedPreferences.setStringList(any(), any())).thenAnswer((_) async => true);

        // Act
        final result = await repository.removeSongFromFavorites(1);

        // Assert
        expect(result, true);
        verify(() => mockSharedPreferences.getStringList(favoritesKey)).called(1);
        verify(() => mockSharedPreferences.setStringList(favoritesKey, ['2'])).called(1);
      });

      test('isSongFavorite should return true if song id is present', () async {
        // Arrange
        when(() => mockSharedPreferences.getStringList(favoritesKey)).thenReturn(['1', '2']);

        // Act
        final result = await repository.isSongFavorite(2);

        // Assert
        expect(result, true);
      });
    });

    group('Session', () {
      test('getSavedQueuesJson should return string from SharedPreferences', () async {
        when(() => mockSharedPreferences.getString(any())).thenReturn('json_data');
        final result = await repository.getSavedQueuesJson();
        expect(result, 'json_data');
      });

      test('saveQueuesJson should save string to SharedPreferences', () async {
        when(() => mockSharedPreferences.setString(any(), any())).thenAnswer((_) async => true);
        final result = await repository.saveQueuesJson('json_data');
        expect(result, true);
      });

      test('getLastSession should return map from SharedPreferences', () async {
        when(() => mockSharedPreferences.getString('last_active_queue_id')).thenReturn('id');
        when(() => mockSharedPreferences.getInt('last_song_index')).thenReturn(1);
        when(() => mockSharedPreferences.getInt('last_position')).thenReturn(100);

        final result = await repository.getLastSession();

        expect(result['activeQueueId'], 'id');
        expect(result['currentIndex'], 1);
        expect(result['positionMs'], 100);
      });
    });
  });
}
