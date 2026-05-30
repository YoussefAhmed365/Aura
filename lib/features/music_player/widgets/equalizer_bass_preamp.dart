import 'package:aura/features/music_player/bloc/equalizer_cubit.dart';
import 'package:aura/features/music_player/domain/models/equalizer_state_model.dart';
import 'package:aura/features/music_player/widgets/custom_knob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EqualizerBassPreamp extends StatelessWidget {
  const EqualizerBassPreamp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EqualizerCubit, EqualizerStateModel>(
      builder: (context, state) {
        final cubit = context.read<EqualizerCubit>();
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
                        value: state.bassValue,
                        size: 150,
                        onChanged: (newBassValue) {
                          cubit.updateBass(newBassValue);
                        },
                      ),
                      const Text("Bass Boost"),
                      Text(state.bassValue.round().toString()),
                    ],
                  ),
                  Column(
                    children: [
                      CircularCustomKnob(
                        value: state.surroundValue,
                        size: 150,
                        onChanged: (newSurrondValue) {
                          cubit.updateSurround(newSurrondValue);
                        },
                      ),
                      const Text("Surrounded Sound"),
                      Text(state.surroundValue.round().toString()),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              const Text("Preamp"),
              Slider(
                value: state.preampValue,
                min: -30,
                max: 0,
                divisions: 30,
                label: state.preampValue.round().toString(),
                onChanged: (double value) {
                  cubit.updatePreamp(value);
                },
              ),
              Text("${state.preampValue.round()} dB"),
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
                        child: state.isStereo ? FilledButton.tonal(onPressed: () {}, child: const Text("Stereo")) : OutlinedButton(onPressed: () => cubit.updateStereoMono(true), child: const Text("Stereo")),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 100,
                        child: !state.isStereo ? FilledButton.tonal(onPressed: () {}, child: const Text("Mono")) : OutlinedButton(onPressed: () => cubit.updateStereoMono(false), child: const Text("Mono")),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      CircularCustomKnob(
                        value: state.balanceValue,
                        min: -100,
                        max: 100,
                        size: 150,
                        onChanged: (value) {
                          cubit.updateBalance(value);
                        },
                      ),
                      SizedBox(
                        width: 110,
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text("L"), Text("R")]),
                      ),
                      const Text("Balance"),
                      Text(state.balanceValue.round().toString()),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
