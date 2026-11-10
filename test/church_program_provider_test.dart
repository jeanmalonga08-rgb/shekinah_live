import 'package:flutter_test/flutter_test.dart';
import 'package:shekinah_live/domain/entities/church_program.dart';
import 'package:shekinah_live/presentation/providers/church_program_provider.dart';

void main() {
  group('upcomingChurchServices', () {
    final recurring = ChurchProgram(
      defaults: const [
        ChurchProgramEntry(
          dayName: 'Dimanche',
          weekday: DateTime.sunday,
          time: '09:30',
          period: 'AM',
        ),
        ChurchProgramEntry(
          dayName: 'Mercredi',
          weekday: DateTime.wednesday,
          time: '17:00',
          period: 'PM',
        ),
      ],
      specials: const [],
    );

    test('returns next occurrence of each recurring service', () {
      // Mardi 10 novembre 2026 → prochain dimanche = 15/11, mercredi = 11/11.
      final now = DateTime(2026, 11, 10, 12);
      final services = upcomingChurchServices(recurring, now: now);

      expect(services, hasLength(2));
      expect(services.first.dateTime, DateTime(2026, 11, 11, 17));
      expect(services.last.dateTime, DateTime(2026, 11, 15, 9, 30));
      expect(services.every((s) => !s.isSpecial), isTrue);
    });

    test('skips today when the service time already passed', () {
      // Dimanche 15 novembre 2026 à 18h → culte de 9h30 déjà passé.
      final now = DateTime(2026, 11, 15, 18);
      final services = upcomingChurchServices(recurring, now: now);

      final sunday = services.firstWhere(
        (s) => s.entry.weekday == DateTime.sunday,
      );
      expect(sunday.dateTime, DateTime(2026, 11, 22, 9, 30));
    });

    test('special events take priority over recurring services', () {
      final dated = ChurchProgram(
        defaults: recurring.defaults,
        specials: [
          ChurchProgramEntry(
            dayName: 'Jeudi',
            weekday: DateTime.thursday,
            date: DateTime(2026, 11, 12),
            time: '09:00',
            period: 'AM',
            label: 'Réunion de Thanksgiving',
          ),
          ChurchProgramEntry(
            dayName: 'Dimanche',
            weekday: DateTime.sunday,
            date: DateTime(2026, 11, 15),
            time: '09:00',
            period: 'AM',
            label: 'Réunion de Thanksgiving',
          ),
        ],
      );

      final now = DateTime(2026, 11, 10, 12);
      final services = upcomingChurchServices(dated, now: now);

      expect(services, hasLength(2));
      expect(services.every((s) => s.isSpecial), isTrue);
      expect(services.first.entry.label, 'Réunion de Thanksgiving');
      expect(services.first.dateTime, DateTime(2026, 11, 12, 9));
      expect(services.last.dateTime, DateTime(2026, 11, 15, 9));

      // Programme vide de spéciaux passés → retour au récurrent.
      final pastSpecials = ChurchProgram(
        defaults: recurring.defaults,
        specials: [
          ChurchProgramEntry(
            dayName: 'Lundi',
            date: DateTime(2026, 11, 2),
            time: '09:00',
            period: 'AM',
          ),
        ],
      );
      final fallback = upcomingChurchServices(pastSpecials, now: now);
      expect(fallback, hasLength(2));
      expect(fallback.every((s) => !s.isSpecial), isTrue);
    });
  });
}
