import 'package:aura/core/widgets/sliver_list_tile.dart';
import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../core/widgets/tob_bar.dart';

class PlaylistModel {
  final String name;
  final int songs;
  final ImageProvider imageProvider;

  const PlaylistModel({required this.name, required this.songs, required this.imageProvider});
}

final List<PlaylistModel> playlists = [const PlaylistModel(imageProvider: AssetImage("assets/images/cover-1.jpg"), name: "Chill Hits", songs: 13), const PlaylistModel(imageProvider: AssetImage("assets/images/cover-2.jpg"), name: "My Playlist", songs: 54), const PlaylistModel(imageProvider: AssetImage("assets/images/cover-3.jpg"), name: "Rock", songs: 27)];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  void requestPermission() async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      await _audioQuery.permissionsRequest();
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        // Page Content
        CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 140)),

            // Playlists Header
            SliverPadding(
              padding: const EdgeInsets.only(left: 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Your Mix", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Playlists Horizontal List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: SizedBox(
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
                                image: DecorationImage(image: playlists[index].imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(playlists[index].name),
                            const SizedBox(height: 5),
                            Text("${playlists[index].songs} Songs", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),

            // Favorites Header
            SliverPadding(
              padding: const EdgeInsets.only(left: 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Favorites", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Favorites List
            BlocBuilder<PlayerBloc, PlayerState>(
              builder: (context, state) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverListTile<SongModel>(
                    items: state.favoriteSongs,
                    artworkType: ArtworkType.AUDIO,
                    title: (song) => song.title,
                    subtitle: (song) => "${song.artist ?? "Unknown"} • ${song.album ?? "Unknown"}",
                    id: (song) => song.id,
                    onTap: (list, index) {
                      context.read<PlayerBloc>().add(PlayAllEvent(songs: list, index: index));
                    },
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),

        // Top Bar
        const TopBar(title: "Aura", subtitle: "Good Evening", hasSearch: true),
      ],
    );
  }
}
