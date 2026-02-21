import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/services/get_song_id.dart';

void main() {
  group('getSongId Tests', () {
    test('يجب أن تُرجع 0 إذا كان الـ songId يساوي null', () {
      final result = getSongId(null);
      expect(result, 0);
    });

    test('يجب أن تستخرج الرقم بنجاح من مسار صحيح', () {
      final result = getSongId('content://media/external/audio/media/12345');
      expect(result, 12345);
    });

    test('يجب أن تُرجع 0 إذا كان النص لا يحتوي على أرقام صالحة', () {
      final result = getSongId('content://media/invalid_id');
      expect(result, 0);
    });
  });
}