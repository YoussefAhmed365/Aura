part of 'player_bloc.dart';

// نموذج يمثل الـ Queue المخصص
class CustomQueue extends Equatable {
  final String id;
  final String name;
  final List<MediaItem> items;

  const CustomQueue({
    required this.id,
    required this.name,
    required this.items,
  });

  CustomQueue copyWith({String? name, List<MediaItem>? items}) {
    return CustomQueue(
      id: id,
      name: name ?? this.name,
      items: items ?? this.items,
    );
  }

  // تحويل من وإلى JSON لحفظها في SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((item) => {
        'id': item.id,
        'album': item.album,
        'title': item.title,
        'artist': item.artist,
        'duration': item.duration?.inMilliseconds,
        'artUri': item.artUri?.toString(),
        'extras': item.extras,
      }).toList(),
    };
  }

  factory CustomQueue.fromJson(Map<String, dynamic> json) {
    return CustomQueue(
      id: json['id'],
      name: json['name'],
      items: (json['items'] as List).map((item) => MediaItem(
        id: item['id'],
        album: item['album'],
        title: item['title'],
        artist: item['artist'],
        duration: item['duration'] != null ? Duration(milliseconds: item['duration']) : null,
        artUri: item['artUri'] != null ? Uri.parse(item['artUri']) : null,
        extras: item['extras'] != null ? Map<String, dynamic>.from(item['extras']) : null,
      )).toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, items];
}

class PlayerState extends Equatable {
  final MediaItem? currentSong;
  final int currentIndex;
  final List<MediaItem> queue; // الـ Queue النشط حالياً
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isBuffering;

  // المتغيرات الجديدة الخاصة بإدارة الـ Queues
  final List<CustomQueue> savedQueues;
  final String? activeQueueId;

  const PlayerState({
    this.currentSong,
    this.currentIndex = 0,
    this.queue = const [],
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isBuffering = false,
    this.savedQueues = const [],
    this.activeQueueId,
  });

  PlayerState copyWith({
    MediaItem? currentSong,
    int? currentIndex,
    List<MediaItem>? queue,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isBuffering,
    List<CustomQueue>? savedQueues,
    String? activeQueueId,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      currentIndex: currentIndex ?? this.currentIndex,
      queue: queue ?? this.queue,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isBuffering: isBuffering ?? this.isBuffering,
      savedQueues: savedQueues ?? this.savedQueues,
      activeQueueId: activeQueueId ?? this.activeQueueId,
    );
  }

  @override
  List<Object?> get props => [
    currentSong,
    currentIndex,
    queue,
    isPlaying,
    position,
    duration,
    isBuffering,
    savedQueues,
    activeQueueId,
  ];
}