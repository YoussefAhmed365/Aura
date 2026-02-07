part of 'player_bloc.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object> get props => [];
}

// Click on song from the list to play
class PlayAllEvent extends PlayerEvent {
  final List<SongModel> songs; // The whole list
  final int index; // Num of song

  const PlayAllEvent({required this.songs, required this.index});

  @override
  List<Object> get props => [songs, index];
}

// Play & Pause
class PlayPauseEvent extends PlayerEvent {}

// Seek with slider
class SeekEvent extends PlayerEvent {
  final Duration position;

  const SeekEvent(this.position);

  @override
  List<Object> get props => [position];
}

// Next & Previous
class SkipNextEvent extends PlayerEvent {}

class SkipPreviousEvent extends PlayerEvent {}

// Internal events for AudioHandler updates
class _MediaItemUpdated extends PlayerEvent {
  final MediaItem mediaItem;
  const _MediaItemUpdated(this.mediaItem);

  @override
  List<Object> get props => [mediaItem];
}

class _PlaybackStateUpdated extends PlayerEvent {
  final bool isPlaying;
  final bool isBuffering;
  const _PlaybackStateUpdated({required this.isPlaying, required this.isBuffering});

  @override
  List<Object> get props => [isPlaying, isBuffering];
}

class _PositionUpdated extends PlayerEvent {
  final Duration position;
  const _PositionUpdated(this.position);

  @override
  List<Object> get props => [position];
}