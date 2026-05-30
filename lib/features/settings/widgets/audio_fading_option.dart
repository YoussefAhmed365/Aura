import 'package:flutter/material.dart';
import 'package:aura/features/settings/presentation/manager/playback_settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AudioFadingOption extends StatelessWidget {
  const AudioFadingOption({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackSettingsCubit, PlaybackSettingsState>(
      builder: (context, state) {
        return Column(
          children: [
            ListTile(
              leading: const Icon(Icons.volume_up_rounded),
              title: const Text("Audio Fading"),
              subtitle: Text(state.fadeEnabled ? "Enabled (Fade In: ${state.fadeStartDuration}s / Fade Out: ${state.fadeEndDuration}s)" : "Disabled"),
              trailing: Switch(
                value: state.fadeEnabled,
                onChanged: (value) => context.read<PlaybackSettingsCubit>().setFadeEnabled(value),
              ),
            ),
            if (state.fadeEnabled) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildDurationSlider(
                      context,
                      label: "Fade In Duration",
                      value: state.fadeStartDuration,
                      onChanged: (v) => context.read<PlaybackSettingsCubit>().setFadeStartDuration(v.toInt()),
                    ),
                    _buildDurationSlider(
                      context,
                      label: "Fade Out Duration",
                      value: state.fadeEndDuration,
                      onChanged: (v) => context.read<PlaybackSettingsCubit>().setFadeEndDuration(v.toInt()),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDurationSlider(BuildContext context, {required String label, required int value, required ValueChanged<double> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text("${value}s", style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 15,
          divisions: 15,
          label: "${value}s",
          onChanged: onChanged,
        ),
      ],
    );
  }
}