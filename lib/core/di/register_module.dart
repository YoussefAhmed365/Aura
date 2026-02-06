import 'package:audio_service/audio_service.dart';
import 'package:aura/features/music_player/services/audio_handler.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  AudioPlayer get audioPlayer => AudioPlayer(); // For Audio Player

  @lazySingleton
  OnAudioQuery get onAudioQuery => OnAudioQuery(); // For Library Of Gitting Data

  @preResolve // Wait until function ends before run the app
  @singleton
  Future<AudioHandler> get audioHandler async {
    return await AudioService.init(
      builder: () => MyAudioHandler(AudioPlayer()),
      config: const AudioServiceConfig(androidNotificationChannelId: 'com.aura.music_player.channel.audio', androidNotificationChannelName: 'Aura Music Player', androidNotificationOngoing: true),
    );
  }
}
