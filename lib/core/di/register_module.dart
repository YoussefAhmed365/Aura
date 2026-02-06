import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  AudioPlayer get audioPlayer => AudioPlayer(); // For Audio Player

  @lazySingleton
  OnAudioQuery get onAudioQuery => OnAudioQuery(); // For Library Of Gitting Data
}