import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Queues extends StatelessWidget {
  final ScrollController scrollController;
  final PageController? pageController;
  const Queues({super.key, required this.scrollController, this.pageController});

  void _showRenameDialog(BuildContext context, String queueId, String currentName) {
    final TextEditingController controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Rename Queue"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter new name",
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  context.read<PlayerBloc>().add(RenameQueueEvent(queueId, controller.text.trim()));
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final queues = state.savedQueues.reversed.toList();

        if (queues.isEmpty) {
          return Center(
            child: Text(
              "No Queues yet.\nPlay a song to create one automatically.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          );
        }

        return RadioGroup<String>(
          groupValue: state.activeQueueId,
          onChanged: (String? value) {
            if (value != null && value != state.activeQueueId) {
              context.read<PlayerBloc>().add(PlaySavedQueueEvent(value));
              // Jump to songs page after selecting a queue
              pageController?.animateToPage(
                1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
          child: ListView.builder(
            controller: scrollController,
            itemCount: queues.length,
            itemBuilder: (context, index) {
              final queue = queues[index];
              final isActive = queue.id == state.activeQueueId;

              return RadioListTile<String>(
                title: Text(
                  queue.name,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text("${queue.items.length} songs"),
                value: queue.id,
                controlAffinity: ListTileControlAffinity.trailing,
                secondary: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'rename') {
                      _showRenameDialog(context, queue.id, queue.name);
                    } else if (value == 'delete') {
                      context.read<PlayerBloc>().add(DeleteQueueEvent(queue.id));
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 10),
                          Text('Rename'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, color: Colors.red),
                          const SizedBox(width: 10),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}