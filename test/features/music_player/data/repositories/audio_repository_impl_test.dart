import 'package:aura/features/music_player/data/repositories/audio_repository_impl.dart';
import 'package:aura/features/music_player/domain/models/custom_queue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MockOnAudioQuery extends Mock implements OnAudioQuery {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockBox<T> extends Mock implements Box<T> {}

class FakeCustomQueue extends Fake implements CustomQueue {}

void main() {
  late AudioRepositoryImpl repository;
  late MockOnAudioQuery mockOnAudioQuery;
  late MockSharedPreferences mockSharedPreferences;
  late MockBox<CustomQueue> mockQueuesBox;
  late MockBox<dynamic> mockSessionBox;
  late MockBox<String> mockLyricsBox;

  setUpAll(() {
    registerFallbackValue(AudiosFromType.ALBUM_ID);
    registerFallbackValue(SongSortType.TITLE);
    registerFallbackValue(OrderType.ASC_OR_SMALLER);
    registerFallbackValue(UriType.EXTERNAL);
    registerFallbackValue(FakeCustomQueue());
  });

  setUp(() {
    mockOnAudioQuery = MockOnAudioQuery();
    mockSharedPreferences = MockSharedPreferences();
    mockQueuesBox = MockBox<CustomQueue>();
    mockSessionBox = MockBox<dynamic>();
    mockLyricsBox = MockBox<String>();

    when(() => mockSharedPreferences.getString('saved_custom_queues')).thenReturn(null);
    when(() => mockSharedPreferences.getString('last_active_queue_id')).thenReturn(null);
    when(() => mockSharedPreferences.getInt('last_song_index')).thenReturn(null);
    when(() => mockSharedPreferences.getInt('last_position')).thenReturn(null);

    repository = AudioRepositoryImpl(
      mockOnAudioQuery, 
      mockSharedPreferences,
      mockQueuesBox,
      mockSessionBox,
      mockLyricsBox,
    );
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
    });

    group('Session & Queues with Hive', () {
      test('getSavedQueues should return list of CustomQueue from Box', () async {
        final mockQueue = CustomQueue(id: '1', name: 'Test', items: []);
        when(() => mockQueuesBox.values).thenReturn([mockQueue]);
        
        final result = await repository.getSavedQueues();
        expect(result, [mockQueue]);
        verify(() => mockQueuesBox.values).called(1);
      });

      test('saveQueue should put CustomQueue in Box', () async {
        final mockQueue = CustomQueue(id: '1', name: 'Test', items: []);
        when(() => mockQueuesBox.put(any(), any())).thenAnswer((_) async => {});
        
        await repository.saveQueue(mockQueue);
        verify(() => mockQueuesBox.put('1', mockQueue)).called(1);
      });

      test('getLastSession should return map from session Box', () async {
        when(() => mockSessionBox.get('activeQueueId')).thenReturn('id');
        when(() => mockSessionBox.get('currentIndex')).thenReturn(1);
        when(() => mockSessionBox.get('positionMs')).thenReturn(100);

        final result = await repository.getLastSession();

        expect(result['activeQueueId'], 'id');
        expect(result['currentIndex'], 1);
        expect(result['positionMs'], 100);
      });
      
      test('saveCurrentSession should put data into session Box', () async {
        when(() => mockSessionBox.put(any(), any())).thenAnswer((_) async => {});
        
        await repository.saveCurrentSession(activeQueueId: 'id', currentIndex: 1, positionMs: 100);
        
        verify(() => mockSessionBox.put('activeQueueId', 'id')).called(1);
        verify(() => mockSessionBox.put('currentIndex', 1)).called(1);
        verify(() => mockSessionBox.put('positionMs', 100)).called(1);
      });
    });
    
    group('Lyrics Cache', () {
      test('getCachedLyrics should return string from lyrics Box', () async {
        when(() => mockLyricsBox.get('song_1')).thenReturn('some lyrics');
        
        final result = await repository.getCachedLyrics('song_1');
        expect(result, 'some lyrics');
      });
      
      test('cacheLyrics should put string in lyrics Box', () async {
        when(() => mockLyricsBox.put(any(), any())).thenAnswer((_) async => {});
        
        await repository.cacheLyrics('song_1', 'some lyrics');
        verify(() => mockLyricsBox.put('song_1', 'some lyrics')).called(1);
      });
    });
  });
}
