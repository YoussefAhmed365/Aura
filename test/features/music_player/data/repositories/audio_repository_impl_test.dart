import 'package:aura/features/music_player/data/repositories/audio_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MockOnAudioQuery extends Mock implements OnAudioQuery {}

void main() {
  late AudioRepositoryImpl audioRepository;
  late MockOnAudioQuery mockOnAudioQuery;

  setUpAll(() {
    registerFallbackValue(AudiosFromType.ALBUM_ID);
  });

  setUp(() {
    mockOnAudioQuery = MockOnAudioQuery();
    audioRepository = AudioRepositoryImpl(mockOnAudioQuery);
  });

  group('AudioRepositoryImpl', () {
    group('getSongs', () {
      test('should return list of songs when permission is granted initially', () async {
        // Arrange
        when(() => mockOnAudioQuery.permissionsStatus()).thenAnswer((_) async => true);
        // We can't easily construct SongModel if it's not exported or complex,
        // but typically it accepts a map.
        // If construction fails, we will adjust.
        // For now, let's assume empty list is fine for "songs" return to verify the flow,
        // or try to construct one if needed. Let's return an empty list for simplicity first
        // unless we need to verify content.
        final expectedSongs = <SongModel>[];
        when(() => mockOnAudioQuery.querySongs(
              sortType: any(named: 'sortType'),
              orderType: any(named: 'orderType'),
              uriType: any(named: 'uriType'),
              ignoreCase: any(named: 'ignoreCase'),
            )).thenAnswer((_) async => expectedSongs);

        // Act
        final result = await audioRepository.getSongs();

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
        final result = await audioRepository.getSongs();

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
        final result = await audioRepository.getSongs();

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

    group('Other methods', () {
      test('getAlbums delegates to queryAlbums', () async {
        when(() => mockOnAudioQuery.queryAlbums()).thenAnswer((_) async => []);
        await audioRepository.getAlbums();
        verify(() => mockOnAudioQuery.queryAlbums()).called(1);
      });

      test('getArtists delegates to queryArtists', () async {
        when(() => mockOnAudioQuery.queryArtists()).thenAnswer((_) async => []);
        await audioRepository.getArtists();
        verify(() => mockOnAudioQuery.queryArtists()).called(1);
      });

      test('getSongsByAlbum delegates to queryAudiosFrom with correct params', () async {
        const albumId = 123;
        when(() => mockOnAudioQuery.queryAudiosFrom(
              any(),
              any(),
              sortType: any(named: 'sortType'),
            )).thenAnswer((_) async => []);

        await audioRepository.getSongsByAlbum(albumId);

        verify(() => mockOnAudioQuery.queryAudiosFrom(
              AudiosFromType.ALBUM_ID,
              albumId,
              sortType: SongSortType.TITLE,
            )).called(1);
      });

      test('getSongsByArtist delegates to queryAudiosFrom with correct params', () async {
        const artistId = 456;
        when(() => mockOnAudioQuery.queryAudiosFrom(
              any(),
              any(),
              sortType: any(named: 'sortType'),
            )).thenAnswer((_) async => []);

        await audioRepository.getSongsByArtist(artistId);

        verify(() => mockOnAudioQuery.queryAudiosFrom(
              AudiosFromType.ARTIST_ID,
              artistId,
              sortType: SongSortType.TITLE,
            )).called(1);
      });
    });
  });
}
