import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:aura/features/music_player/presentation/song_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAudioHandler extends BaseAudioHandler {
  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> skipToNext() async {}

  @override
  Future<void> skipToPrevious() async {}
}

void main() {
  late PlayerBloc playerBloc;
  late MockAudioHandler audioHandler;

  setUp(() {
    audioHandler = MockAudioHandler();
    playerBloc = PlayerBloc(audioHandler, positionStream: const Stream.empty());
  });

  tearDown(() {
    playerBloc.close();
  });

  testWidgets('SongPlayerScreen renders correctly', (WidgetTester tester) async {
    // Provide a large enough surface to avoid overflow issues in test
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<PlayerBloc>.value(
          value: playerBloc,
          child: const SongPlayerScreen(),
        ),
      ),
    );

    // Allow animations and async tasks to settle
    // pumpAndSettle times out due to infinite scrolling text animation
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SongPlayerScreen), findsOneWidget);

    // Verify control buttons exist
    expect(find.byIcon(Icons.skip_previous_rounded), findsOneWidget);
    expect(find.byIcon(Icons.fast_rewind_rounded), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.byIcon(Icons.fast_forward_rounded), findsOneWidget);
    expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);

    // Reset view size
    addTearDown(tester.view.resetPhysicalSize);
  });
}
