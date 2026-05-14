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
  // 1. Assign SharedPreferences to save settings (such: last song played)
  // We used @preResolve because this library need time for initialization (await) before app starting
  @preResolve
  @singleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  // 2. Assign actual audio player (Internal Engine)
  @lazySingleton
  AudioPlayer get audioPlayer => AudioPlayer();

  // 3. Assign query library we used in AudioRepositoryImpl
  @lazySingleton
  OnAudioQuery get onAudioQuery => OnAudioQuery();

  // 4. assign background audio service (AudioService) to play music even when app is closed
  @preResolve
  @singleton
  Future<AudioHandler> get audioHandler async {
    return await AudioService.init(
      builder: () => AuraAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.codev.aura.music_player.channel.audio',
        androidNotificationChannelName: 'Aura Music Player',
        androidNotificationOngoing: true, // Keep the notification turned on to not to close the player
      ),
    );
  }

  // 5. Hive Boxes
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