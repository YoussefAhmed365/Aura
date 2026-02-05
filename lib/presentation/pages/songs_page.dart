import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  // 2. إنشاء نسخة من OnAudioQuery
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text("Aura - Songs", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),

          Expanded(
            child: FutureBuilder<List<SongModel>>(
              future: _audioQuery.querySongs(
                sortType: null, // ترتيب افتراضي
                orderType: OrderType.ASC_OR_SMALLER,
                uriType: UriType.EXTERNAL, // البحث في الذاكرة الخارجية
                ignoreCase: true,
              ),
              builder: (context, item) {
                // Loading
                if (item.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // If There's No Music
                if (item.data == null || item.data!.isEmpty) {
                  return const Center(child: Text("No songs found!"));
                }

                // Show Music
                return Scrollbar(
                  thickness: 6,
                  radius: const Radius.circular(10),
                  interactive: true,
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: item.data!.length,
                    itemBuilder: (context, index) {
                      // Get Song Info
                      SongModel song = item.data![index];

                      return ListTile(
                        title: Text(
                          song.title,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          song.artist ?? "Unknown Artist",
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Song Cover (ArtWork)
                        leading: QueryArtworkWidget(
                          id: song.id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: const Icon(Icons.music_note),
                        ),
                        onTap: () {
                          // هنا يمكنك إضافة كود تشغيل الأغنية لاحقاً
                          // مثلاً باستخدام just_audio
                          print("Playing ${song.title}");
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}