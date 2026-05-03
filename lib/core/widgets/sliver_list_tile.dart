import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SliverListTile<T> extends StatelessWidget {
  final Future<List<T>> future;
  final ArtworkType artworkType;
  final String Function(T) title;
  final String Function(T) subtitle;
  final int Function(T) id;
  final void Function(List<T> list, int index) onTap;
  final IconData placeholderIcon;
  final VoidCallback? onMorePressed;

  const SliverListTile({super.key, required this.future, required this.artworkType, required this.title, required this.subtitle, required this.id, required this.onTap, this.placeholderIcon = Icons.music_note, this.onMorePressed});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10),
      sliver: FutureBuilder<List<T>>(
        future: future,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator()));
          }

          // Error
          if (snapshot.hasError) {
            return SliverFillRemaining(hasScrollBody: false, child: Center(child: Text("Error: ${snapshot.error}")));
          }

          // Empty
          final items = snapshot.data;
          if (items == null || items.isEmpty) {
            return const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text("No items found!")));
          }

          // List Items
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: InkWell(
                  onTap: () => onTap(items, index),
                  splashColor: Theme.of(context).colorScheme.surface,
                  child: Row(
                    children: [
                      // Rounded Artwork
                      QueryArtworkWidget(
                        id: id(item),
                        type: artworkType,
                        artworkWidth: 60,
                        artworkHeight: 60,
                        artworkBorder: BorderRadius.circular(10),
                        keepOldArtwork: true,
                        nullArtworkWidget: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(color: Colors.grey.withAlpha(26), borderRadius: BorderRadius.circular(10)),
                          child: Icon(placeholderIcon, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Item Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title(item),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle(item),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // More Options Icon
                      IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.grey),
                        onPressed: onMorePressed ?? () {},
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: items.length),
          );
        },
      ),
    );
  }
}
