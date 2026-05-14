import 'package:audio_service/audio_service.dart';
import 'package:hive/hive.dart';

class MediaItemAdapter extends TypeAdapter<MediaItem> {
  @override
  final int typeId = 1;

  @override
  MediaItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaItem(
      id: fields[0] as String,
      album: fields[1] as String?,
      title: fields[2] as String,
      artist: fields[3] as String?,
      duration: fields[4] != null ? Duration(milliseconds: fields[4] as int) : null,
      artUri: fields[5] != null ? Uri.parse(fields[5] as String) : null,
      extras: fields[6] != null ? Map<String, dynamic>.from(fields[6] as Map) : null,
    );
  }

  @override
  void write(BinaryWriter writer, MediaItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.album)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.artist)
      ..writeByte(4)
      ..write(obj.duration?.inMilliseconds)
      ..writeByte(5)
      ..write(obj.artUri?.toString())
      ..writeByte(6)
      ..write(obj.extras);
  }
}
