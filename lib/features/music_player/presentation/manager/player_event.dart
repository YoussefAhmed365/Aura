part of 'player_bloc.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayAllEvent extends PlayerEvent {
  final List<SongModel> songs;
  final int index;

  const PlayAllEvent({required this.songs, required this.index});

  @override
  List<Object> get props => [songs, index];
}

class PlaySongsByIdsEvent extends PlayerEvent {
  final List<int> ids;
  final int initialIndex;

  const PlaySongsByIdsEvent({required this.ids, this.initialIndex = 0});
}

class PlayPauseEvent extends PlayerEvent {}

class SeekEvent extends PlayerEvent {
  final Duration position;

  const SeekEvent(this.position);

  @override
  List<Object> get props => [position];
}

class SkipNextEvent extends PlayerEvent {}

class SkipPreviousEvent extends PlayerEvent {}

class ToggleFavoriteEvent extends PlayerEvent {
  final int songId;

  const ToggleFavoriteEvent(this.songId);

  @override
  List<Object> get props => [songId];
}

class LoadFavoritesEvent extends PlayerEvent {}

class CheckFavoriteStatusEvent extends PlayerEvent {
  final int songId;

  const CheckFavoriteStatusEvent(this.songId);

  @override
  List<Object> get props => [songId];
}

// ----------------- أحداث الـ Queues الجديدة -----------------

// حدث لتشغيل أغنية معينة من الـ Queue النشط حالياً
class PlaySpecificQueueItemEvent extends PlayerEvent {
  final int index;

  const PlaySpecificQueueItemEvent(this.index);

  @override
  List<Object> get props => [index];
}

// حدث لتشغيل Queue محفوظ مسبقاً
class PlaySavedQueueEvent extends PlayerEvent {
  final String queueId;

  const PlaySavedQueueEvent(this.queueId);

  @override
  List<Object> get props => [queueId];
}

class DeleteQueueEvent extends PlayerEvent {
  final String queueId;

  const DeleteQueueEvent(this.queueId);

  @override
  List<Object> get props => [queueId];
}

class RenameQueueEvent extends PlayerEvent {
  final String queueId;
  final String newName;

  const RenameQueueEvent(this.queueId, this.newName);

  @override
  List<Object> get props => [queueId, newName];
}

class LoadSavedQueuesEvent extends PlayerEvent {}

class ReorderQueueEvent extends PlayerEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderQueueEvent(this.oldIndex, this.newIndex);

  @override
  List<Object> get props => [oldIndex, newIndex];
}

// ------------------------------------------------------------

class _MediaItemUpdated extends PlayerEvent {
  final MediaItem? mediaItem;

  const _MediaItemUpdated(this.mediaItem);

  @override
  List<Object?> get props => [mediaItem];
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

class _QueueUpdated extends PlayerEvent {
  final List<MediaItem> queue;

  const _QueueUpdated(this.queue);

  @override
  List<Object> get props => [queue];
}
