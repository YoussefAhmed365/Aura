import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Text("Aura - Settings", style: Theme.of(context).textTheme.titleLarge)]);
  }
}
