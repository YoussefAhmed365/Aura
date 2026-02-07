part of 'player_bloc.dart';

class PlayerState extends Equatable {
  final MediaItem? currentSong;
  final bool isPlaying;
  final Duration position; // current position
  final Duration duration; // duarion of song
  final bool isBuffering; // حالة التحميل (Buffering/Loading) مهمة للمستخدم

  const PlayerState({this.currentSong, this.isPlaying = false, this.position = Duration.zero, this.duration = Duration.zero, this.isBuffering = false});

  // دالة لنسخ الحالة مع تعديل بسيط (Copy with)
  PlayerState copyWith({MediaItem? currentSong, bool? isPlaying, Duration? position, Duration? duration, bool? isBuffering}) {
    return PlayerState(currentSong: currentSong ?? this.currentSong, isPlaying: isPlaying ?? this.isPlaying, position: position ?? this.position, duration: duration ?? this.duration, isBuffering: isBuffering ?? this.isBuffering);
  }

  @override
  List<Object?> get props => [currentSong, isPlaying, position, duration, isBuffering];
}
