import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // 1. External Services (External Libraries)
  getIt.registerLazySingleton<AudioPlayer>(() => AudioPlayer());

  // هنا سنقوم لاحقاً بتسجيل الـ AudioHandler والـ Repositories
  // مثال (سيتم تفعيله لاحقاً):
  // getIt.registerSingleton<AudioHandler>(await initAudioService());
}