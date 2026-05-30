import 'package:equatable/equatable.dart';

class EqualizerStateModel extends Equatable {
  final bool isEnabled;
  final String selectedAudioSource;
  final String selectedPreset;
  final List<double> gains; // 10 bands
  final double bassValue;
  final double surroundValue;
  final double preampValue;
  final double balanceValue; // Pan left/right (-100 to 100)
  final bool isStereo;
  final List<String> customPresets;
  final Map<String, List<double>> customPresetsGains;

  const EqualizerStateModel({
    required this.isEnabled,
    required this.selectedAudioSource,
    required this.selectedPreset,
    required this.gains,
    required this.bassValue,
    required this.surroundValue,
    required this.preampValue,
    required this.balanceValue,
    required this.isStereo,
    required this.customPresets,
    required this.customPresetsGains,
  });

  factory EqualizerStateModel.initial() {
    return const EqualizerStateModel(
      isEnabled: true,
      selectedAudioSource: "device_audio",
      selectedPreset: "Normal",
      gains: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      bassValue: 0,
      surroundValue: 0,
      preampValue: 0,
      balanceValue: 0,
      isStereo: true,
      customPresets: [],
      customPresetsGains: {},
    );
  }

  EqualizerStateModel copyWith({
    bool? isEnabled,
    String? selectedAudioSource,
    String? selectedPreset,
    List<double>? gains,
    double? bassValue,
    double? surroundValue,
    double? preampValue,
    double? balanceValue,
    bool? isStereo,
    List<String>? customPresets,
    Map<String, List<double>>? customPresetsGains,
  }) {
    return EqualizerStateModel(
      isEnabled: isEnabled ?? this.isEnabled,
      selectedAudioSource: selectedAudioSource ?? this.selectedAudioSource,
      selectedPreset: selectedPreset ?? this.selectedPreset,
      gains: gains ?? this.gains,
      bassValue: bassValue ?? this.bassValue,
      surroundValue: surroundValue ?? this.surroundValue,
      preampValue: preampValue ?? this.preampValue,
      balanceValue: balanceValue ?? this.balanceValue,
      isStereo: isStereo ?? this.isStereo,
      customPresets: customPresets ?? this.customPresets,
      customPresetsGains: customPresetsGains ?? this.customPresetsGains,
    );
  }

  factory EqualizerStateModel.fromJson(Map<String, dynamic> json) {
    return EqualizerStateModel(
      isEnabled: json['isEnabled'] as bool? ?? true,
      selectedAudioSource: json['selectedAudioSource'] as String? ?? "device_audio",
      selectedPreset: json['selectedPreset'] as String? ?? "Normal",
      gains: (json['gains'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? List.filled(10, 0.0),
      bassValue: (json['bassValue'] as num?)?.toDouble() ?? 0.0,
      surroundValue: (json['surroundValue'] as num?)?.toDouble() ?? 0.0,
      preampValue: (json['preampValue'] as num?)?.toDouble() ?? 0.0,
      balanceValue: (json['balanceValue'] as num?)?.toDouble() ?? 0.0,
      isStereo: json['isStereo'] as bool? ?? true,
      customPresets: (json['customPresets'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      customPresetsGains: (json['customPresetsGains'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as List<dynamic>).map((e) => (e as num).toDouble()).toList())) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'selectedAudioSource': selectedAudioSource,
      'selectedPreset': selectedPreset,
      'gains': gains,
      'bassValue': bassValue,
      'surroundValue': surroundValue,
      'preampValue': preampValue,
      'balanceValue': balanceValue,
      'isStereo': isStereo,
      'customPresets': customPresets,
      'customPresetsGains': customPresetsGains,
    };
  }

  @override
  List<Object?> get props => [
        isEnabled,
        selectedAudioSource,
        selectedPreset,
        gains,
        bassValue,
        surroundValue,
        preampValue,
        balanceValue,
        isStereo,
        customPresets,
        customPresetsGains,
      ];
}
