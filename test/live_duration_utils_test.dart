import 'package:flutter_test/flutter_test.dart';
import 'package:shekinah_live/core/utils/live_duration_utils.dart';
import 'package:shekinah_live/domain/entities/church_program.dart';

void main() {
  group('formatLiveDuration', () {
    test('shows days instead of accumulating hours past 24', () {
      expect(
        formatLiveDuration(const Duration(hours: 69, minutes: 23, seconds: 46)),
        '2d 21:23:46',
      );
    });

    test('keeps the existing hour format below one day', () {
      expect(
        formatLiveDuration(const Duration(hours: 9, minutes: 4)),
        '09:04:00',
      );
    });

    test('clamps negative durations to zero', () {
      expect(formatLiveDuration(const Duration(seconds: -1)), '00:00');
    });
  });
  test('utilise le debut du culte a Kinshasa pendant le direct', () {
    final program = ChurchProgram(
      defaults: const [],
      specials: [
        ChurchProgramEntry(
          dayName: 'Jeudi',
          date: DateTime(2026, 11, 12),
          time: '09:00',
        ),
      ],
    );
    expect(
      liveWorshipElapsed(
        program,
        DateTime.utc(2026, 11, 12, 8, 30),
        now: DateTime.utc(2026, 11, 12, 8, 55),
      ),
      const Duration(minutes: 55),
    );
  });

  test('utilise le debut du direct sans programme', () {
    expect(
      liveWorshipElapsed(
        null,
        DateTime.utc(2026, 11, 12, 8),
        now: DateTime.utc(2026, 11, 12, 8, 30),
      ),
      const Duration(minutes: 30),
    );
  });
}
