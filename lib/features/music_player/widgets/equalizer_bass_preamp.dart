import 'package:aura/features/music_player/widgets/custom_knob.dart';
import 'package:flutter/material.dart';

class EqualizerBassPreamp extends StatefulWidget {
  const EqualizerBassPreamp({super.key});

  @override
  State<EqualizerBassPreamp> createState() => _EqualizerBassPreampState();
}

class _EqualizerBassPreampState extends State<EqualizerBassPreamp> {
  double bassValue = 0;
  double surroundValue = 0;
  double preampValue = 0;
  double balanceValue = 0;
  bool isStereo = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  CircularCustomKnob(
                    value: bassValue,
                    size: 150,
                    onChanged: (newBassValue) {
                      setState(() {
                        bassValue = newBassValue;
                      });
                    },
                  ),
                  const Text("Bass Boost"),
                  Text(bassValue.round().toString()),
                ],
              ),
              Column(
                children: [
                  CircularCustomKnob(
                    value: surroundValue,
                    size: 150,
                    onChanged: (newSurrondValue) {
                      setState(() {
                        surroundValue = newSurrondValue;
                      });
                    },
                  ),
                  const Text("Surrounded Sound"),
                  Text(surroundValue.round().toString()),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          const Text("Preamp"),
          Slider(
            value: preampValue,
            min: -30,
            max: 0,
            divisions: 30,
            label: preampValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                preampValue = value;
              });
            },
          ),
          Text("${preampValue.round()} dB"),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text("Channel"),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 100,
                    child: isStereo ? FilledButton.tonal(onPressed: () {}, child: const Text("Stereo")) : OutlinedButton(onPressed: () => setState(() => isStereo = true), child: const Text("Stereo")),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 100,
                    child: !isStereo ? FilledButton.tonal(onPressed: () {}, child: const Text("Mono")) : OutlinedButton(onPressed: () => setState(() => isStereo = false), child: const Text("Mono")),
                  ),
                ],
              ),
              Column(
                children: [
                  CircularCustomKnob(
                    value: balanceValue,
                    min: -100,
                    max: 100,
                    size: 150,
                    onChanged: (value) {
                      setState(() {
                        balanceValue = value;
                      });
                    },
                  ),
                  SizedBox(
                    width: 110,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text("L"), Text("R")]),
                  ),
                  const Text("Balance"),
                  Text(balanceValue.round().toString()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
