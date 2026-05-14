part of 'player_bloc.dart';

class PlayerState extends Equatable {
  final MediaItem? currentSong;
  final int currentIndex;
  final List<MediaItem> queue; // الـ Queue النشط حالياً
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isBuffering;
  final List<int> favoritesSongIds;
  final List<SongModel> favoriteSongs;
  final bool isFavorite;

  // المتغيرات الجديدة الخاصة بإدارة الـ Queues
  final List<CustomQueue> savedQueues;
  final String? activeQueueId;

  const PlayerState({this.currentSong, this.currentIndex = 0, this.queue = const [], this.isPlaying = false, this.position = Duration.zero, this.duration = Duration.zero, this.isBuffering = false, this.savedQueues = const [], this.activeQueueId, this.favoritesSongIds = const [], this.favoriteSongs = const [], this.isFavorite = false});

  PlayerState copyWith({MediaItem? currentSong, int? currentIndex, List<MediaItem>? queue, bool? isPlaying, Duration? position, Duration? duration, bool? isBuffering, List<CustomQueue>? savedQueues, String? activeQueueId, List<int>? favoritesSongIds, List<SongModel>? favoriteSongs, bool? isFavorite}) {
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
      favoritesSongIds: favoritesSongIds ?? this.favoritesSongIds,
      favoriteSongs: favoriteSongs ?? this.favoriteSongs,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [currentSong, currentIndex, queue, isPlaying, position, duration, isBuffering, savedQueues, activeQueueId, favoritesSongIds, favoriteSongs, isFavorite];
}
