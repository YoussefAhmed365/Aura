import 'dart:ui';

import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.white.withAlpha(16), Colors.white.withAlpha(5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(30)),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Aura", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text("Good Evening", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70)),
                ],
              ),
              const Spacer(),
              Container(
                decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                child: IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded), iconSize: 24, color: Colors.white, padding: const EdgeInsets.all(10), constraints: const BoxConstraints()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}