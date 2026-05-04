import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentQueueSongs extends StatefulWidget {
  final ScrollController scrollController;
  final PageController? pageController;
  final bool isNowPlayingClick;

  const CurrentQueueSongs({
    super.key,
    required this.scrollController,
    this.pageController,
    this.isNowPlayingClick = false,
  });

  @override
  State<CurrentQueueSongs> createState() => _CurrentQueueSongsState();
}

class _CurrentQueueSongsState extends State<CurrentQueueSongs> {
  final double _itemHeight = 72.0;

  void _scrollToCurrent(int index) {
    if (!widget.scrollController.hasClients || index < 0) return;

    // Check if this page is active if a PageController is provided
    if (widget.pageController != null) {
      if (widget.pageController!.hasClients && widget.pageController!.page?.round() != 1) {
        return; 
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.scrollController.hasClients) return;
      
      final double offset = index * _itemHeight;
      final double maxScroll = widget.scrollController.position.maxScrollExtent;
      final double targetOffset = offset.clamp(0.0, maxScroll);

      widget.scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _pageListener() {
    if (widget.pageController?.page?.round() == 1) {
      final state = context.read<PlayerBloc>().state;
      _scrollToCurrent(state.currentIndex);
    }
  }

  @override
  void initState() {
    super.initState();
    widget.pageController?.addListener(_pageListener);
    
    if (widget.isNowPlayingClick) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          final state = context.read<PlayerBloc>().state;
          _scrollToCurrent(state.currentIndex);
        }
      });
    }
  }

  @override
  void dispose() {
    widget.pageController?.removeListener(_pageListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlayerBloc, PlayerState>(
      listenWhen: (previous, current) => 
          previous.currentIndex != current.currentIndex || 
          previous.activeQueueId != current.activeQueueId,
      listener: (context, state) {
        _scrollToCurrent(state.currentIndex);
      },
      builder: (context, state) {
        final currentQueueItems = state.queue;
        final currentIndex = state.currentIndex;

        if (currentQueueItems.isEmpty) {
          return Center(
            child: Text(
              "Current queue is empty.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          );
        }

        return ReorderableListView.builder(
          scrollController: widget.scrollController,
          itemCount: currentQueueItems.length,
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            context.read<PlayerBloc>().add(ReorderQueueEvent(oldIndex, newIndex));
          },
          buildDefaultDragHandles: false,
          itemBuilder: (context, index) {
            final item = currentQueueItems[index];
            final isPlaying = index == currentIndex;

            return GestureDetector(
              key: ValueKey(item.id),
              onLongPressStart: (LongPressStartDetails details) {
                showMenu(
                  context: context,
                  popUpAnimationStyle: AnimationStyle(duration: const Duration(milliseconds: 600)),
                  // Define the position of the popup menu
                  position: RelativeRect.fromLTRB(
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                  ),
                  items: <PopupMenuEntry>[
                    const PopupMenuItem(
                      value: 'info',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('File information'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.remove_circle_outline, size: 20),
                          SizedBox(width: 10),
                          Text('Remove from queue'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'play_after_current',
                      child: Row(
                        children: [
                          Icon(Icons.skip_next, size: 20),
                          SizedBox(width: 10),
                          Text('Play after current song'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'add_to_playlists',
                      child: Row(
                        children: [
                          Icon(Icons.playlist_add, size: 20),
                          SizedBox(width: 10),
                          Text('Add to playlists'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'preview',
                      child: Row(
                        children: [
                          Icon(Icons.play_circle_outline_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('Preview'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'stop_after_this_song',
                      child: Row(
                        children: [
                          Icon(Icons.pause_circle_outline_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('Stop after this song'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 10),
                          Text('Edit tags'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('Share'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'select',
                      child: Row(
                        children: [
                          Icon(Icons.check_box_outlined, size: 20),
                          SizedBox(width: 10),
                          Text('Select song'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'select_all',
                      child: Row(
                        children: [
                          Icon(Icons.select_all_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('Select all songs'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('Delete permanently'),
                        ],
                      ),
                    ),
                  ],
                ).then((value) {
                  if (value == 'remove') {
                    // context.read<PlayerBloc>().add(RemoveFromQueueEvent(index));
                  }
                });
              },
              child: ListTile(
                leading: ReorderableDragStartListener(
                  index: index,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.menu_rounded),
                  ),
                ),
                title: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isPlaying ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  item.artist ?? "Unknown Artist",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isPlaying ? Theme.of(context).colorScheme.primary.withAlpha(150) : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: isPlaying ? Icon(Icons.equalizer_rounded, color: Theme.of(context).colorScheme.primary) : null,
                onTap: () {
                  if (!isPlaying) {
                    context.read<PlayerBloc>().add(PlaySpecificQueueItemEvent(index));
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}