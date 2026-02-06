// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:just_audio/just_audio.dart' as _i501;
import 'package:on_audio_query/on_audio_query.dart' as _i859;

import '../../features/music_player/data/repositories/audio_repository_impl.dart'
    as _i398;
import '../../features/music_player/domain/repositories/audio_repository.dart'
    as _i889;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i501.AudioPlayer>(() => registerModule.audioPlayer);
    gh.lazySingleton<_i859.OnAudioQuery>(() => registerModule.onAudioQuery);
    gh.lazySingleton<_i889.AudioRepository>(
      () => _i398.AudioRepositoryImpl(gh<_i859.OnAudioQuery>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
