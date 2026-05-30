import 'package:flutter/material.dart';

class EqualizerSliders extends StatefulWidget {
  const EqualizerSliders({super.key});

  @override
  State<EqualizerSliders> createState() => _EqualizerSlidersState();
}

class _EqualizerSlidersState extends State<EqualizerSliders> {
  bool _isEnabled = true;
  String _selectedAudioSource = "bluetooth_device";
  final presets = {
    "default_presets": ["Normal", "Bass Boost", "Mid Boost", "Triple Boost"],
    "custom_presets": ["Good preset", "My Equalizer"],
  };
  String _selectedPreset = "Normal";
  final List<double> _gains = List.generate(10, (index) => 0.0);
  final List<String> _frequencies = ['31.5', '63', '125', '250', '500', '1k', '2k', '4k', '8k', '16k'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: _isEnabled ? Theme.of(context).colorScheme.onPrimaryFixedVariant : Theme.of(context).colorScheme.onPrimary, width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedAudioSource,
                  underline: const SizedBox.shrink(),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: "device_audio", child: Text("Device Audio")),
                    // Current connected bluetooth audio source
                    DropdownMenuItem(value: "bluetooth_device", child: Text("Realme Buds T110")),
                    // Old bluetooth device
                    DropdownMenuItem(value: "bluetooth_device_old", enabled: false, child: Text("Z303")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedAudioSource = value);
                    }
                  },
                ),
              ),
              Switch(
                value: _isEnabled,
                onChanged: (value) {
                  setState(() => _isEnabled = value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            PopupMenuButton<String>(
              initialValue: _selectedPreset,
              onSelected: (String value) {
                setState(() => _selectedPreset = value);
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
                items.addAll(presets["default_presets"]!.map((preset) => PopupMenuItem(value: preset, child: Text(preset))));

                // Add Custom Presets section
                if (presets["custom_presets"]!.isNotEmpty) {
                  items.add(const PopupMenuDivider());
                  items.add(
                    const PopupMenuItem(
                      enabled: false,
                      child: Text("Custom Presets", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  );
                  items.addAll(presets["custom_presets"]!.map((preset) => PopupMenuItem(value: preset, child: Text(preset))));
                }

                // Ensure Custom (volatile) is visible if selected
                if (_selectedPreset == "Custom") {
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
                child: Text(_selectedPreset),
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
                            setState(() {
                              presets["custom_presets"]?.add(controller.text);
                              _selectedPreset = controller.text;
                            });
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
                          Text("${_gains[index].toInt()}dB", style: const TextStyle(fontSize: 12)),
                          Expanded(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Slider(
                                value: _gains[index],
                                min: -15,
                                max: 15,
                                activeColor: _isEnabled ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                                inactiveColor: _isEnabled ? Theme.of(context).colorScheme.surfaceContainer : Theme.of(context).disabledColor.withAlpha(50),
                                onChanged: _isEnabled
                                    ? (value) {
                                        setState(() {
                                          _gains[index] = value;
                                          _selectedPreset = "Custom";
                                        });
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
  }
}
