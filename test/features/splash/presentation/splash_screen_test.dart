import 'package:aura/core/di/injection.dart';
import 'package:aura/features/splash/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MockOnAudioQuery extends Mock implements OnAudioQuery {}

void main() {
  setUp(() async {
    await getIt.reset();
    getIt.registerLazySingleton<OnAudioQuery>(() => MockOnAudioQuery());
  });

  testWidgets('renders generic error and retry button without sensitive error details', (tester) async {
    final mockOnAudioQuery = getIt<OnAudioQuery>() as MockOnAudioQuery;
    when(() => mockOnAudioQuery.permissionsStatus()).thenThrow(Exception('Sensitive Error Detail'));

    await tester.pumpWidget(const MaterialApp(home: AppStart()));
    await tester.pumpAndSettle();

    expect(find.text('Initialization Error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.textContaining('Sensitive Error Detail'), findsNothing);
  });
}
