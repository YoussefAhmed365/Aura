import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // تسجيل مشغل الصوت كـ Lazy Singleton (نسخة واحدة تظل موجودة بالذاكرة)
  getIt.registerLazySingleton<AudioPlayer>(() => AudioPlayer());

  // تسجيل مستعلم الملفات الصوتية
  getIt.registerLazySingleton<OnAudioQuery>(() => OnAudioQuery());
}