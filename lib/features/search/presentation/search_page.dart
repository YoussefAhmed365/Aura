import 'package:aura/core/di/injection.dart';
import 'package:aura/core/widgets/sliver_list_tile.dart';
import 'package:aura/core/widgets/tob_bar.dart';
import 'package:aura/features/music_player/domain/repositories/audio_repository.dart';
import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  // Use Future to show the results with initially Null to not to show anything at the beginnig
  Future<List<SongModel>>? _searchFuture;

  // Search function called only when Enter is pressed
  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchFuture = null; // Clear results if text is empty
      });
      return;
    }

    setState(() {
      // Fetch all songs then filter them locally
      _searchFuture = getIt<AudioRepository>().getSongs().then((songs) {
        final lowerQuery = query.toLowerCase();
        return songs.where((song) {
          final titleMatch = song.title.toLowerCase().contains(lowerQuery);
          final albumMatch = song.album?.toLowerCase().contains(lowerQuery) ?? false;
          final artistMatch = song.artist?.toLowerCase().contains(lowerQuery) ?? false;

          // Return song if query matches title, album, or artist
          return titleMatch || albumMatch || artistMatch;
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Bar
        // hasSearchBar is set to false to avoid duplication with the TextField below.
        const TopBar(title: "Search", hasSearchBar: false),

        // Search Field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: _performSearch, // Search is triggered here only on Enter
            decoration: InputDecoration(
              hintText: "Search for a title, album, or artist...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  _performSearch("");
                },
              )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.grey.withAlpha(25),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),

        // Search Results
        Expanded(
          child: _searchFuture == null
          // Default screen before any search is performed
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 64, color: Colors.grey.withAlpha(100)),
                const SizedBox(height: 16),
                Text("Type and press Enter to search", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              ],
            ),
          )
          // Display results using CustomScrollView to be compatible with SliverListTile
              : CustomScrollView(
            slivers: [
              SliverListTile<SongModel>(
                future: _searchFuture!,
                artworkType: ArtworkType.AUDIO,
                title: (song) => song.title,
                subtitle: (song) => "${song.artist ?? "Unknown"} • ${song.album ?? "Unknown"}",
                id: (song) => song.id,
                onTap: (list, index) {
                  context.read<PlayerBloc>().add(PlayAllEvent(songs: list, index: index));
                },
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100), // Padding for MiniPlayer
              ),
            ],
          ),
        ),
      ],
    );
  }
}
