import 'package:flutter/material.dart';

class SongsPage extends StatelessWidget {
  const SongsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [Text("Aura - Songs", style: Theme.of(context).textTheme.titleLarge)]),
    );
  }
}
