import 'package:flutter_test/flutter_test.dart';
import 'package:shekinah_live/core/utils/next_worship_service.dart';

void main() {
  group('NextWorshipService.isDuringWorshipService', () {
    test('true on Sunday during morning service', () {
      final sunday = DateTime(2026, 9, 6, 10, 0); // Sunday 10:00
      expect(NextWorshipService.isDuringWorshipService(sunday), isTrue);
    });

    test('false on Sunday before service', () {
      final sunday = DateTime(2026, 9, 6, 8, 0);
      expect(NextWorshipService.isDuringWorshipService(sunday), isFalse);
    });

    test('true on Wednesday evening service', () {
      final wednesday = DateTime(2026, 9, 9, 18, 30);
      expect(NextWorshipService.isDuringWorshipService(wednesday), isTrue);
    });

    test('false on Monday', () {
      final monday = DateTime(2026, 9, 7, 12, 0);
      expect(NextWorshipService.isDuringWorshipService(monday), isFalse);
    });
  });
}
