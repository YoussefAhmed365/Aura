import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool hasSearch;
  final bool hasSearchBar;

  const TopBar({super.key, required this.title, this.subtitle, this.hasSearch = false, this.hasSearchBar = false});

  static double height = 70;

  @override
  Widget build(BuildContext context) {
    if (subtitle != null && hasSearchBar) {
      height = 166;
    } else if (hasSearchBar) {
      height = 140;
    } else if (subtitle != null) {
      height = 100;
    }

    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Theme.of(context).colorScheme.surface.withAlpha(16), Theme.of(context).colorScheme.surface.withAlpha(5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.surface.withAlpha(30)),
            ),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
                        if (subtitle != null) Text(subtitle!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary)),
                      ],
                    ),
                    if (hasSearch) const Spacer(),
                    if (hasSearch)
                      Container(
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.inverseSurface.withAlpha(76), shape: BoxShape.circle),
                        child: IconButton(
                          onPressed: () {
                            context.read<NavigationCubit>().setTab(2);
                          },
                          icon: const Icon(Icons.search_rounded),
                          iconSize: 24,
                          color: Theme.of(context).colorScheme.onSurface,
                          padding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                  ],
                ),

                if (hasSearchBar) const SizedBox(height: 20),
                if (hasSearchBar)
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(hintText: "Search for anything...", prefixIcon: Icon(Icons.search), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);

  void setTab(int index) => emit(index);
}
