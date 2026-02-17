import 'package:flutter/material.dart';

class Playlists extends StatelessWidget {
  const Playlists({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10, bottom: 80),
      sliver: SliverToBoxAdapter(child: Center(child: Text("Playlists"))),
    );
  }
}
