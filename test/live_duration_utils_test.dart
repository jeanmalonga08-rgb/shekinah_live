import 'package:flutter_test/flutter_test.dart';
import 'package:shekinah_live/core/utils/live_duration_utils.dart';

void main() {
  group('formatLiveDuration', () {
    test('shows days instead of accumulating hours past 24', () {
      expect(
        formatLiveDuration(
          const Duration(hours: 69, minutes: 23, seconds: 46),
        ),
        '2d 21:23:46',
      );
    });

    test('keeps the existing hour format below one day', () {
      expect(formatLiveDuration(const Duration(hours: 9, minutes: 4)), '09:04:00');
    });

    test('clamps negative durations to zero', () {
      expect(formatLiveDuration(const Duration(seconds: -1)), '00:00');
    });
  });
}