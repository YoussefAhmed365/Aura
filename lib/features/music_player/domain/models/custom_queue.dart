import 'package:audio_service/audio_service.dart';
import 'package:equatable/equatable.dart';

class CustomQueue extends Equatable {
  final String id;
  final String name;
  final List<MediaItem> items;

  const CustomQueue({
    required this.id,
    required this.name,
    required this.items,
  });

  CustomQueue copyWith({
    String? name,
    List<MediaItem>? items,
  }) {
    return CustomQueue(
      id: id,
      name: name ?? this.name,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [id, name, items];
}
