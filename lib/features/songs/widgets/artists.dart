import 'package:flutter/material.dart';

class Artists extends StatelessWidget {
  const Artists({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      sliver: SliverToBoxAdapter(child: Center(child: Text("Artists"))),
    );
  }
}
