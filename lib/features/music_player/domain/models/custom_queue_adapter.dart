import 'package:aura/features/music_player/domain/models/custom_queue.dart';
import 'package:audio_service/audio_service.dart';
import 'package:hive/hive.dart';

class CustomQueueAdapter extends TypeAdapter<CustomQueue> {
  @override
  final int typeId = 0;

  @override
  CustomQueue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomQueue(
      id: fields[0] as String,
      name: fields[1] as String,
      items: (fields[2] as List).cast<MediaItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, CustomQueue obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomQueueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
