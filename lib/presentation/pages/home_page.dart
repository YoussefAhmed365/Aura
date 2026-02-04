import 'package:flutter/material.dart';
import 'package:aura/presentation/widgets/top_bar.dart';

final List<Map<String, dynamic>> playlists = [
  {"image": "assets/images/cover-1.jpg", "name": "Chill Hits", "songs": 13},
  {"image": "assets/images/cover-2.jpg", "name": "My Playlist", "songs": 54},
  {"image": "assets/images/cover-3.jpg", "name": "Rock", "songs": 27},
];

final List<Map<String, dynamic>> favorites = [
  {"name": "Faded", "author": "Alan Walker", "album": "Alan Walker", "duration": "3:32"},
  {"name": "Blinding Lights", "author": "The Weeknd", "album": null, "duration": "3:20"},
  {"name": "Shape of You", "author": "Ed Sheeran", "album": "Ed Sheeran", "duration": "3:53"},
  {"name": "Someone You Loved", "author": "Lewis Capaldi", "album": "Lewis Capaldi", "duration": "3:02"},
  {"name": "Dance Monkey", "author": "Tones and I", "album": null, "duration": "3:29"},
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Page Content
        SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 140),
                Text("Your Mix", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(image: AssetImage(playlists[index]['image']), fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(playlists[index]['name']),
                            const SizedBox(height: 5),
                            Text("${playlists[index]['songs']} Songs", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Text("Favorites", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favorites.length,
                    separatorBuilder: (context, index) {
                      return const Divider(thickness: 0.15, height: 20, color: Colors.grey);
                    },
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.music_note_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        title: Text(favorites[index]['name'] ?? 'Unknown Title', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(favorites[index]['author'] ?? 'Unknown Artist', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            if (favorites[index]['album'] != null) Text(favorites[index]['album'] as String, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(favorites[index]['duration'] ?? '--:--', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            const SizedBox(width: 15),
                            Icon(Icons.more_vert_rounded, color: Theme.of(context).colorScheme.onSurface),
                          ],
                        ),
                        onTap: () {},
                      );
                    },
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // Top Bar
        Positioned(top: 20, left: 20, right: 20, height: 100, child: TopBar()),
      ],
    );
  }
}
