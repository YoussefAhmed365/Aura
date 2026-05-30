import 'package:aura/core/di/injection.dart';
import 'package:aura/features/music_player/bloc/equalizer_cubit.dart';
import 'package:aura/features/music_player/widgets/equalizer_bass_preamp.dart';
import 'package:aura/features/music_player/widgets/equalizer_sliders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  int pageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: pageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<EqualizerCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Equalizer", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
          centerTitle: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      pageIndex = index;
                    });
                  },
                  scrollDirection: Axis.horizontal,
                  children: const [EqualizerSliders(), EqualizerBassPreamp()],
                ),
              ),
              const SizedBox(width: 150, child: Divider()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                    icon: Icon(Icons.equalizer_rounded, size: 32, color: pageIndex == 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline),
                  ),
                  IconButton(
                    onPressed: () {
                      _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                    icon: Icon(Icons.multitrack_audio_rounded, size: 32, color: pageIndex == 1 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
