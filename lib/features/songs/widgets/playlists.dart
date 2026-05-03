import 'package:aura/core/di/injection.dart';
import 'package:aura/features/music_player/domain/repositories/audio_repository.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:aura/features/songs/presentation/song_list_by_entity.dart';

class Playlists extends StatefulWidget {
  const Playlists({super.key});

  @override
  State<Playlists> createState() => _PlaylistsState();
}

class _PlaylistsState extends State<Playlists> {
  late Future<List<PlaylistModel>> _playlistsFuture;

  @override
  void initState() {
    super.initState();
    _fetchPlaylists();
  }

  void _fetchPlaylists() {
    setState(() {
      _playlistsFuture = getIt<AudioRepository>().getPlaylists();
    });
  }

  void _showCreatePlaylistDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Create Playlist"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter playlist name",
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  await getIt<AudioRepository>().createPlaylist(controller.text.trim());
                  if (context.mounted) {
                    Navigator.pop(context);
                    _fetchPlaylists(); // Refresh List
                  }
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: InkWell(
        onTap: _showCreatePlaylistDialog,
        borderRadius: BorderRadius.circular(15),
        splashColor: Theme.of(context).colorScheme.primary.withAlpha(50),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withAlpha(100),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha(50)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withAlpha(100), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Icon(Icons.add_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create Playlist",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 4),
                    Text("Build your own custom mix", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary.withAlpha(150))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistTile(BuildContext context, PlaylistModel playlist) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SongListByEntity(id: playlist.id, title: playlist.playlist, isArtist: false, isPlaylist: true),
            ),
          ).then((_) => _fetchPlaylists()); // Refresh in case songs were removed/added
        },
        child: Row(
          children: [
            QueryArtworkWidget(
              id: playlist.id,
              type: ArtworkType.PLAYLIST,
              artworkWidth: 60,
              artworkHeight: 60,
              artworkBorder: BorderRadius.circular(10),
              keepOldArtwork: true,
              nullArtworkWidget: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.queue_music_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 15),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.playlist,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${playlist.numOfSongs} songs",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // More Options Dropdown
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) async {
                if (value == 'delete') {
                  await getIt<AudioRepository>().removePlaylist(playlist.id);
                  _fetchPlaylists();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 10),
                      Text('Delete Playlist', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10),
      sliver: FutureBuilder<List<PlaylistModel>>(
        future: _playlistsFuture,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final hasError = snapshot.hasError;
          final playlists = snapshot.data ?? [];
          final isEmpty = playlists.isEmpty && !isLoading && !hasError;

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Item 0 is always the Create button
                if (index == 0) {
                  return _buildCreateButton(context);
                }

                // Handling states visually inside the list
                if (isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(child: Text("Error fetching playlists")),
                  );
                }

                if (isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Text(
                        "No playlists found!\nCreate one using the button above.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ),
                  );
                }

                // Render playlist items
                final playlist = playlists[index - 1];
                return _buildPlaylistTile(context, playlist);
              },
              // Total items: 1 (button) + dynamically determined items
              childCount: (isLoading || hasError || isEmpty) ? 2 : playlists.length + 1,
            ),
          );
        },
      ),
    );
  }
}
