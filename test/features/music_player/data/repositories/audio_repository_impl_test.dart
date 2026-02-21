import 'package:aura/features/music_player/data/repositories/audio_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MockOnAudioQuery extends Mock implements OnAudioQuery {}

void main() {
  late AudioRepositoryImpl repository;
  late MockOnAudioQuery mockOnAudioQuery;

  setUpAll(() {
    registerFallbackValue(AudiosFromType.ALBUM_ID);
    registerFallbackValue(SongSortType.TITLE);
    registerFallbackValue(OrderType.ASC_OR_SMALLER);
    registerFallbackValue(UriType.EXTERNAL);
  });

  setUp(() {
    mockOnAudioQuery = MockOnAudioQuery();
    repository = AudioRepositoryImpl(mockOnAudioQuery);
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
              sortType: SongSortType.TITLE,
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
              sortType: SongSortType.TITLE,
            )).called(1);
      });
    });
  });
}
