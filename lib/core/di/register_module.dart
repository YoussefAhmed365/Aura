import 'package:audio_service/audio_service.dart';
import 'package:aura/core/services/audio_handler.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:aura/features/music_player/domain/models/custom_queue.dart';

@module
abstract class RegisterModule {
  @preResolve
  @singleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  AndroidEqualizer get androidEqualizer => AndroidEqualizer();

  @lazySingleton
  AndroidLoudnessEnhancer get androidLoudnessEnhancer => AndroidLoudnessEnhancer();

  // AndroidBassBoost doesn't exist in just_audio out of the box in 0.10.5 without an extra extension or it was removed,
  // so we'll omit it for now and only initialize available effects.

  // 2. Assign actual audio player (Internal Engine)
  @lazySingleton
  AudioPlayer get audioPlayer {
    return AudioPlayer(
      audioPipeline: AudioPipeline(
        androidAudioEffects: [
          androidEqualizer,
          androidLoudnessEnhancer,
        ],
      ),
    );
  }

  @lazySingleton
  OnAudioQuery get onAudioQuery => OnAudioQuery();

  @preResolve
  @singleton
  Future<AudioHandler> get audioHandler async {
    return await AudioService.init(
      builder: () => AuraAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.codev.aura.music_player.channel.audio',
        androidNotificationChannelName: 'Aura Music Player',
        androidNotificationOngoing: true,
      ),
    );
  }

  @preResolve
  @Named('customQueuesBox')
  @singleton
  Future<Box<CustomQueue>> get customQueuesBox async => await Hive.openBox<CustomQueue>('customQueuesBox');

  @preResolve
  @Named('sessionBox')
  @singleton
  Future<Box<dynamic>> get sessionBox async => await Hive.openBox('sessionBox');

  @preResolve
  @Named('lyricsBox')
  @singleton
  Future<Box<String>> get lyricsBox async => await Hive.openBox<String>('lyricsBox');
}
