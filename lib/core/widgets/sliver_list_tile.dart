import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SliverListTile<T> extends StatelessWidget {
  final Future<List<T>>? future;
  final List<T>? items;
  final ArtworkType artworkType;
  final String Function(T) title;
  final String Function(T) subtitle;
  final int Function(T) id;
  final void Function(List<T> list, int index) onTap;
  final IconData placeholderIcon;
  final VoidCallback? onMorePressed;

  const SliverListTile({super.key, this.future, this.items, required this.artworkType, required this.title, required this.subtitle, required this.id, required this.onTap, this.placeholderIcon = Icons.music_note, this.onMorePressed});

  @override
  Widget build(BuildContext context) {
    if (items != null) {
      return _buildList(context, items!);
    }

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

          return _buildList(context, items);
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<T> items) {
    final themeData = Theme.of(context);
    final theme = themeData.textTheme;
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: InkWell(
            onTap: () => onTap(items, index),
            splashColor: themeData.colorScheme.surface,
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
                        style: theme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle(item),
                        style: theme.labelMedium?.copyWith(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // More Options Icon
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onPressed:
                      onMorePressed ??
                      () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.7, // 70% of screen height
                                  maxWidth: 400, // Fixed width looks cleaner on tablets/web
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 5),
                                  child: Column(
                                    children: [
                                      Text(
                                        title(item),
                                        style: theme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Expanded(
                                        child: ListView(
                                          shrinkWrap: true, // Crucial: makes the list only as tall as its items
                                          children: [
                                            _buildDialogItem(context, Icons.info_outline_rounded, 'File information', 'info'),
                                            _buildDialogItem(context, Icons.remove_circle_outline, 'Remove from queue', 'remove'),
                                            const Divider(),
                                            _buildDialogItem(context, Icons.skip_next, 'Play after current song', 'play_after_current'),
                                            _buildDialogItem(context, Icons.playlist_play_rounded, 'Add to a queue', 'add_to_queue'),
                                            _buildDialogItem(context, Icons.playlist_add, 'Add to playlists', 'add_to_playlists'),
                                            const Divider(),
                                            _buildDialogItem(context, Icons.play_circle_outline_rounded, 'Preview', 'preview'),
                                            _buildDialogItem(context, Icons.pause_circle_outline_rounded, 'Stop after this song', 'stop_after_this_song'),
                                            _buildDialogItem(context, Icons.edit, 'Edit tags', 'edit'),
                                            _buildDialogItem(context, Icons.share_rounded, 'Share', 'share'),
                                            const Divider(),
                                            _buildDialogItem(context, Icons.check_box_outlined, 'Select song', 'select'),
                                            _buildDialogItem(context, Icons.select_all_rounded, 'Select all songs', 'select_all'),
                                            _buildDialogItem(context, Icons.delete_rounded, 'Delete permanently', 'delete'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ).then((value) {
                          if (value == 'remove') {
                            // Handle your logic here
                          }
                        });
                      },
                ),
              ],
            ),
          ),
        );
      }, childCount: items.length),
    );
  }
}

// Helper method to keep code clean
Widget _buildDialogItem(BuildContext context, IconData icon, String label, String value) {
  return ListTile(
    leading: Icon(icon, size: 25),
    title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
    onTap: () => Navigator.pop(context, value),
  );
}
