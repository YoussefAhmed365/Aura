import 'package:audio_service/audio_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaybackSettingsState extends Equatable {
  final bool fadeEnabled;
  final int fadeStartDuration; // In seconds
  final int fadeEndDuration; // In seconds

  const PlaybackSettingsState({
    required this.fadeEnabled,
    required this.fadeStartDuration,
    required this.fadeEndDuration,
  });

  factory PlaybackSettingsState.initial() {
    return const PlaybackSettingsState(
      fadeEnabled: false,
      fadeStartDuration: 3,
      fadeEndDuration: 3,
    );
  }

  PlaybackSettingsState copyWith({
    bool? fadeEnabled,
    int? fadeStartDuration,
    int? fadeEndDuration,
  }) {
    return PlaybackSettingsState(
      fadeEnabled: fadeEnabled ?? this.fadeEnabled,
      fadeStartDuration: fadeStartDuration ?? this.fadeStartDuration,
      fadeEndDuration: fadeEndDuration ?? this.fadeEndDuration,
    );
  }

  @override
  List<Object?> get props => [fadeEnabled, fadeStartDuration, fadeEndDuration];
}

@injectable
class PlaybackSettingsCubit extends Cubit<PlaybackSettingsState> {
  final SharedPreferences _prefs;
  final AudioHandler _audioHandler;

  static const String _fadeEnabledKey = 'fade_enabled';
  static const String _fadeStartDurationKey = 'fade_start_duration';
  static const String _fadeEndDurationKey = 'fade_end_duration';

  PlaybackSettingsCubit(this._prefs, this._audioHandler) : super(PlaybackSettingsState.initial()) {
    _loadSettings();
  }

  void _loadSettings() {
    final enabled = _prefs.getBool(_fadeEnabledKey) ?? false;
    final startDuration = _prefs.getInt(_fadeStartDurationKey) ?? 3;
    final endDuration = _prefs.getInt(_fadeEndDurationKey) ?? 3;

    emit(state.copyWith(
      fadeEnabled: enabled,
      fadeStartDuration: startDuration,
      fadeEndDuration: endDuration,
    ));

    _syncToAudioHandler();
  }

  Future<void> setFadeEnabled(bool enabled) async {
    await _prefs.setBool(_fadeEnabledKey, enabled);
    emit(state.copyWith(fadeEnabled: enabled));
    _syncToAudioHandler();
  }

  Future<void> setFadeStartDuration(int duration) async {
    await _prefs.setInt(_fadeStartDurationKey, duration);
    emit(state.copyWith(fadeStartDuration: duration));
    _syncToAudioHandler();
  }

  Future<void> setFadeEndDuration(int duration) async {
    await _prefs.setInt(_fadeEndDurationKey, duration);
    emit(state.copyWith(fadeEndDuration: duration));
    _syncToAudioHandler();
  }

  void _syncToAudioHandler() {
    _audioHandler.customAction('action_update_fade_settings', {
      'enabled': state.fadeEnabled,
      'startDuration': state.fadeStartDuration,
      'endDuration': state.fadeEndDuration,
    });
  }
}
