part of 'player_bloc.dart';

class PlayerState extends Equatable {
  final MediaItem? currentSong;
  final int currentIndex;
  final List<MediaItem> queue;
  final bool isPlaying;
  final Duration position; // current position
  final Duration duration; // duration of song
  final bool isBuffering; // حالة التحميل (Buffering/Loading) مهمة للمستخدم

  const PlayerState({
    this.currentSong,
    this.currentIndex = 0,
    this.queue = const [],
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isBuffering = false,
  });

  // دالة لنسخ الحالة مع تعديل بسيط (Copy with)
  PlayerState copyWith({
    MediaItem? currentSong,
    int? currentIndex,
    List<MediaItem>? queue,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isBuffering,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      currentIndex: currentIndex ?? this.currentIndex,
      queue: queue ?? this.queue,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isBuffering: isBuffering ?? this.isBuffering,
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
      ];
}
