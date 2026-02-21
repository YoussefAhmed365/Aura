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

    test('يجب أن تُرجع 0 إذا كان النص فارغاً', () {
      final result = getSongId('');
      expect(result, 0);
    });

    test('يجب أن تُرجع الرقم إذا كان النص رقماً بدون مسار', () {
      final result = getSongId('99');
      expect(result, 99);
    });

    test('يجب أن تُرجع 0 إذا انتهى المسار بعلامة / فقط', () {
      // split('/').last will be '', int.parse('') throws
      final result = getSongId('content://media/');
      expect(result, 0);
    });

    test('يجب أن تتعامل مع أرقام كبيرة جداً', () {
      final result = getSongId(
        'content://media/external/audio/media/2147483647',
      );
      expect(result, 2147483647);
    });
  });
}
