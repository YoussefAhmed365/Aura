import 'package:aura/features/music_player/bloc/equalizer_cubit.dart';
import 'package:aura/features/music_player/domain/models/equalizer_state_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EqualizerSliders extends StatelessWidget {
  const EqualizerSliders({super.key});

  final List<String> _frequencies = const ['31.5', '63', '125', '250', '500', '1k', '2k', '4k', '8k', '16k'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EqualizerCubit, EqualizerStateModel>(
      builder: (context, state) {
        final cubit = context.read<EqualizerCubit>();

        return Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: state.isEnabled ? Theme.of(context).colorScheme.onPrimaryFixedVariant : Theme.of(context).colorScheme.onPrimary, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: state.selectedAudioSource,
                      underline: const SizedBox.shrink(),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: "device_audio", child: Text("Device Audio")),
                        DropdownMenuItem(value: "bluetooth_device", child: Text("Realme Buds T110")),
                        DropdownMenuItem(value: "bluetooth_device_old", enabled: false, child: Text("Z303")),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          cubit.updateAudioSource(value);
                        }
                      },
                    ),
                  ),
                  Switch(
                    value: state.isEnabled,
                    onChanged: (value) {
                      cubit.updateEnabled(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                PopupMenuButton<String>(
                  initialValue: state.selectedPreset,
                  onSelected: (String value) {
                    cubit.applyPreset(value);
                  },
                  itemBuilder: (context) {
                    List<PopupMenuEntry<String>> items = [];

                    // Add Default Presets section
                    items.add(const PopupMenuDivider());
                    items.add(
                      const PopupMenuItem(
                        enabled: false,
                        child: Text("Default", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    );
                    items.addAll(cubit.defaultPresets.keys.map((preset) => PopupMenuItem(value: preset, child: Text(preset))));

                    // Add Custom Presets section
                    if (state.customPresets.isNotEmpty) {
                      items.add(const PopupMenuDivider());
                      items.add(
                        const PopupMenuItem(
                          enabled: false,
                          child: Text("Custom Presets", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      );
                      items.addAll(state.customPresets.map((preset) => PopupMenuItem(value: preset, child: Text(preset))));
                    }

                    // Ensure Custom (volatile) is visible if selected
                    if (state.selectedPreset == "Custom") {
                      items.insert(0, const PopupMenuItem(value: "Custom", child: Text("Custom")));
                    }

                    // Remove the first divider if it exists
                    if (items.isNotEmpty && items.first is PopupMenuDivider) {
                      items.removeAt(0);
                    }

                    return items;
                  },
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(side: BorderSide(color: Theme.of(context).colorScheme.onSecondary)),
                    child: Text(state.selectedPreset),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    final controller = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Save Preset"),
                        content: TextField(
                          controller: controller,
                          decoration: const InputDecoration(hintText: "Preset Name"),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                          TextButton(
                            onPressed: () {
                              if (controller.text.isNotEmpty) {
                                cubit.saveCustomPreset(controller.text);
                                Navigator.pop(context);
                              }
                            },
                            child: const Text("Save"),
                          ),
                        ],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(side: BorderSide(color: Theme.of(context).colorScheme.onSecondary)),
                  icon: const Icon(Icons.save_rounded),
                  label: const Text("Save"),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: SizedBox(
                  height: 400,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(10, (index) {
                        return SizedBox(
                          width: 38,
                          child: Column(
                            children: [
                              Text("${state.gains[index].toInt()}dB", style: const TextStyle(fontSize: 12)),
                              Expanded(
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Slider(
                                    value: state.gains[index],
                                    min: -15,
                                    max: 15,
                                    activeColor: state.isEnabled ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                                    inactiveColor: state.isEnabled ? Theme.of(context).colorScheme.surfaceContainer : Theme.of(context).disabledColor.withAlpha(50),
                                    onChanged: state.isEnabled
                                        ? (value) {
                                            cubit.updateGain(index, value);
                                          }
                                        : null,
                                  ),
                                ),
                              ),
                              Text(_frequencies[index], style: Theme.of(context).textTheme.labelSmall),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
