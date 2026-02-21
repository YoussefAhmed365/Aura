int getSongId(String? songId) {
  if (songId == null) return 0;
  String idString = songId.split('/').last;
  try {
    return int.parse(idString);
  } catch (e) {
    return 0;
  }
}