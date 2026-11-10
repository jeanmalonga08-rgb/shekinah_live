import 'package:flutter_test/flutter_test.dart';
import 'package:shekinah_live/core/utils/next_worship_service.dart';
import 'package:shekinah_live/domain/entities/church_program.dart';

void main() {
  group('NextWorshipService.isDuringWorshipService', () {
    test('true on Sunday during morning service', () {
      final sunday = DateTime(2026, 9, 6, 10, 0); // Sunday 10:00
      expect(NextWorshipService.isDuringWorshipService(now: sunday), isTrue);
    });

    test('false on Sunday before service', () {
      final sunday = DateTime(2026, 9, 6, 8, 0);
      expect(NextWorshipService.isDuringWorshipService(now: sunday), isFalse);
    });

    test('true on Wednesday evening service', () {
      final wednesday = DateTime(2026, 9, 9, 18, 30);
      expect(
        NextWorshipService.isDuringWorshipService(now: wednesday),
        isTrue,
      );
    });

    test('false on Monday', () {
      final monday = DateTime(2026, 9, 7, 12, 0);
      expect(NextWorshipService.isDuringWorshipService(now: monday), isFalse);
    });
  });

  group('NextWorshipService with remote program', () {
    final program = ChurchProgram(
      defaults: const [
        ChurchProgramEntry(
          dayName: 'Dimanche',
          weekday: DateTime.sunday,
          time: '09:30',
          period: 'AM',
        ),
        ChurchProgramEntry(
          dayName: 'Jeudi',
          weekday: DateTime.thursday,
          time: '17:00',
          period: 'PM',
        ),
      ],
      specials: const [
        ChurchProgramEntry(
          dayName: 'Mardi',
          date: null,
          time: '16:00',
          period: 'PM',
          label: 'Réunion spéciale',
        ),
      ],
    );

    test('detects service window from remote schedule', () {
      // Mercredi 11 nov. 2026, 10h — pas de culte → false.
      expect(
        NextWorshipService.isDuringWorshipService(
          now: DateTime(2026, 11, 11, 10),
          program: program,
        ),
        isFalse,
      );
      // Jeudi 12 nov. 2026, 18h — culte du soir → true.
      expect(
        NextWorshipService.isDuringWorshipService(
          now: DateTime(2026, 11, 12, 18),
          program: program,
        ),
        isTrue,
      );
      // Dimanche 15 nov. 2026, 10h30 — culte du matin → true.
      expect(
        NextWorshipService.isDuringWorshipService(
          now: DateTime(2026, 11, 15, 10, 30),
          program: program,
        ),
        isTrue,
      );
    });

    test('compute returns next remote service', () {
      // Mardi 10 nov. 2026, 12h → prochain = jeudi 12/11 17h00.
      final next = NextWorshipService.compute(
        program: program,
        now: DateTime(2026, 11, 10, 12),
      );
      expect(next.dateTime, DateTime(2026, 11, 12, 17));
      expect(next.timeText, '17:00');
    });
  });
}
