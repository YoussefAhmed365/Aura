import 'package:flutter/material.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Text("Aura - Playlists", style: Theme.of(context).textTheme.titleLarge)]);
  }
}
