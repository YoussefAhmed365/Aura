import 'package:flutter/material.dart';

class Albums extends StatelessWidget {
  const Albums({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      sliver: SliverToBoxAdapter(child: Center(child: Text("Albums"))),
    );
  }
}
