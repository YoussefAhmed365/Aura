import 'package:aura/features/music_player/data/repositories/audio_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MockOnAudioQuery extends Mock implements OnAudioQuery {}

void main() {
  late AudioRepositoryImpl repository;
  late MockOnAudioQuery mockOnAudioQuery;

  setUp(() {
    mockOnAudioQuery = MockOnAudioQuery();
    repository = AudioRepositoryImpl(mockOnAudioQuery);
  });

  group('AudioRepositoryImpl', () {
    test('getSongs should return list of songs when permission is granted', () async {
      // Arrange
      when(() => mockOnAudioQuery.permissionsStatus()).thenAnswer((_) async => true);
      when(() => mockOnAudioQuery.querySongs(
            sortType: any(named: 'sortType'),
            orderType: any(named: 'orderType'),
            uriType: any(named: 'uriType'),
            ignoreCase: any(named: 'ignoreCase'),
          )).thenAnswer((_) async => []);

      // Act
      final result = await repository.getSongs();

      // Assert
      expect(result, isA<List<SongModel>>());
      verify(() => mockOnAudioQuery.permissionsStatus()).called(1);
      verify(() => mockOnAudioQuery.querySongs(
            sortType: SongSortType.DATE_ADDED,
            orderType: OrderType.DESC_OR_GREATER,
            uriType: UriType.EXTERNAL,
            ignoreCase: true,
          )).called(1);
      verifyNever(() => mockOnAudioQuery.permissionsRequest());
    });

    test('getSongs should return list of songs when permission is denied initially but granted on request', () async {
      // Arrange
      when(() => mockOnAudioQuery.permissionsStatus()).thenAnswer((_) async => false);
      when(() => mockOnAudioQuery.permissionsRequest()).thenAnswer((_) async => true);
      when(() => mockOnAudioQuery.querySongs(
            sortType: any(named: 'sortType'),
            orderType: any(named: 'orderType'),
            uriType: any(named: 'uriType'),
            ignoreCase: any(named: 'ignoreCase'),
          )).thenAnswer((_) async => []);

      // Act
      final result = await repository.getSongs();

      // Assert
      expect(result, isA<List<SongModel>>());
      verify(() => mockOnAudioQuery.permissionsStatus()).called(1);
      verify(() => mockOnAudioQuery.permissionsRequest()).called(1);
      verify(() => mockOnAudioQuery.querySongs(
            sortType: SongSortType.DATE_ADDED,
            orderType: OrderType.DESC_OR_GREATER,
            uriType: UriType.EXTERNAL,
            ignoreCase: true,
          )).called(1);
    });

    test('getSongs should return empty list when permission is denied and request is denied', () async {
      // Arrange
      when(() => mockOnAudioQuery.permissionsStatus()).thenAnswer((_) async => false);
      when(() => mockOnAudioQuery.permissionsRequest()).thenAnswer((_) async => false);

      // Act
      final result = await repository.getSongs();

      // Assert
      expect(result, isEmpty);
      verify(() => mockOnAudioQuery.permissionsStatus()).called(1);
      verify(() => mockOnAudioQuery.permissionsRequest()).called(1);
      // It should NOT call querySongs if permission is denied
      verifyNever(() => mockOnAudioQuery.querySongs(
            sortType: any(named: 'sortType'),
            orderType: any(named: 'orderType'),
            uriType: any(named: 'uriType'),
            ignoreCase: any(named: 'ignoreCase'),
          ));
    });
  });
}
