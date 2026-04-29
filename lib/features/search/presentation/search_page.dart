import 'package:aura/core/widgets/tob_bar.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top Bar
        const TopBar(title: "Search", hasSearchBar: true),
      ],
    );
  }
}
