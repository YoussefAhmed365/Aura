import 'package:flutter/material.dart';

class SongsPage extends StatelessWidget {
  const SongsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
              children: [
                Text("Aura - Songs", style: Theme.of(context).textTheme.titleLarge)
              ],
            ),
          ),
        ),
    );
  }
}