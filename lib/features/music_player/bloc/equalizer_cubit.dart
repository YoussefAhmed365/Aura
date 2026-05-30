import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:aura/features/music_player/domain/models/equalizer_state_model.dart';
import 'package:just_audio/just_audio.dart';

@injectable
class EqualizerCubit extends Cubit<EqualizerStateModel> {
  final SharedPreferences prefs;
  final AndroidEqualizer androidEqualizer;
  final AndroidLoudnessEnhancer androidLoudnessEnhancer;

  static const String _prefsKey = 'aura_equalizer_state';

  // Default Presets as per original UI + JustAudio Android Equalizer default presets mapping
  final Map<String, List<double>> defaultPresets = {
    "Normal": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    "Bass Boost": [6, 5, 4, 3, 0, 0, 0, 0, 0, 0],
    "Mid Boost": [0, 0, 2, 4, 5, 5, 4, 2, 0, 0],
    "Triple Boost": [0, 0, 0, 0, 0, 0, 3, 4, 5, 6],
  };

  EqualizerCubit({
    required this.prefs,
    required this.androidEqualizer,
    required this.androidLoudnessEnhancer,
  }) : super(EqualizerStateModel.initial()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final String? savedStateJson = prefs.getString(_prefsKey);
    if (savedStateJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(savedStateJson);
        final EqualizerStateModel savedState = EqualizerStateModel.fromJson(json);
        emit(savedState);
      } catch (e) {
        // Fallback to initial state on parsing error
        emit(EqualizerStateModel.initial());
      }
    } else {
      emit(EqualizerStateModel.initial());
    }
    await _applySettingsToAudioEngine(state);
  }

  Future<void> _saveSettings() async {
    final String jsonString = jsonEncode(state.toJson());
    await prefs.setString(_prefsKey, jsonString);
  }

  Future<void> _applySettingsToAudioEngine(EqualizerStateModel currentState) async {
    try {
      // 1. Equalizer setup
      await androidEqualizer.setEnabled(currentState.isEnabled);
      if (currentState.isEnabled) {
        final params = await androidEqualizer.parameters;
        if (params.bands.length == 10) {
          for (int i = 0; i < 10; i++) {
            // Check boundaries
            final double minGain = params.minDecibels;
            final double maxGain = params.maxDecibels;

            final double clampedGain = currentState.gains[i].clamp(minGain, maxGain);
            await params.bands[i].setGain(clampedGain);
          }
        }
      }

      // 2. Preamp (Loudness Enhancer) setup
      await androidLoudnessEnhancer.setEnabled(currentState.isEnabled && currentState.preampValue != 0);
      if (currentState.isEnabled && currentState.preampValue != 0) {
         // preampValue from UI is -30 to 0 (in dB).
         // For demonstration, map preampValue to targetGain.
         // However, LoudnessEnhancer targetGain is usually in mB and primarily used for boosting.
         await androidLoudnessEnhancer.setTargetGain(currentState.preampValue);
      }
    } catch (e) {
      // Print error or ignore if device does not support effects
      // print("Error applying audio effects: $e");
    }
  }

  Future<void> updateEnabled(bool isEnabled) async {
    final newState = state.copyWith(isEnabled: isEnabled);
    emit(newState);
    await _applySettingsToAudioEngine(newState);
    await _saveSettings();
  }

  Future<void> updateGain(int bandIndex, double value) async {
    final newGains = List<double>.from(state.gains);
    newGains[bandIndex] = value;
    final newState = state.copyWith(gains: newGains, selectedPreset: "Custom");
    emit(newState);
    await _applySettingsToAudioEngine(newState);
    await _saveSettings();
  }

  Future<void> applyPreset(String presetName) async {
    List<double> presetGains = state.gains;
    if (defaultPresets.containsKey(presetName)) {
      presetGains = defaultPresets[presetName]!;
    } else if (state.customPresetsGains.containsKey(presetName)) {
      presetGains = state.customPresetsGains[presetName]!;
    } else {
      return; // preset not found
    }

    final newState = state.copyWith(selectedPreset: presetName, gains: presetGains);
    emit(newState);
    await _applySettingsToAudioEngine(newState);
    await _saveSettings();
  }

  Future<void> saveCustomPreset(String presetName) async {
    final newCustomPresets = List<String>.from(state.customPresets);
    if (!newCustomPresets.contains(presetName)) {
      newCustomPresets.add(presetName);
    }

    final newCustomPresetsGains = Map<String, List<double>>.from(state.customPresetsGains);
    newCustomPresetsGains[presetName] = List<double>.from(state.gains);

    final newState = state.copyWith(
      selectedPreset: presetName,
      customPresets: newCustomPresets,
      customPresetsGains: newCustomPresetsGains,
    );
    emit(newState);
    await _saveSettings();
  }

  Future<void> updateBass(double value) async {
    final newState = state.copyWith(bassValue: value);
    emit(newState);
    await _applySettingsToAudioEngine(newState);
    await _saveSettings();
  }

  Future<void> updateSurround(double value) async {
    final newState = state.copyWith(surroundValue: value);
    emit(newState);
    await _applySettingsToAudioEngine(newState);
    await _saveSettings();
  }

  Future<void> updatePreamp(double value) async {
    final newState = state.copyWith(preampValue: value);
    emit(newState);
    await _applySettingsToAudioEngine(newState);
    await _saveSettings();
  }

  Future<void> updateBalance(double value) async {
    final newState = state.copyWith(balanceValue: value);
    emit(newState);
    await _saveSettings();
  }

  Future<void> updateStereoMono(bool isStereo) async {
    final newState = state.copyWith(isStereo: isStereo);
    emit(newState);
    await _saveSettings();
  }

  Future<void> updateAudioSource(String source) async {
    final newState = state.copyWith(selectedAudioSource: source);
    emit(newState);
    await _saveSettings();
  }
}
