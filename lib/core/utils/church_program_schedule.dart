import '../../domain/entities/church_program.dart';

/// Culte à venir calculé pour l'affichage.
class UpcomingChurchService {
  const UpcomingChurchService({
    required this.entry,
    required this.dateTime,
    required this.isSpecial,
  });

  final ChurchProgramEntry entry;
  final DateTime dateTime;
  final bool isSpecial;
}

/// Prochains cultes, même logique que shekinahgospel.org :
/// les événements spéciaux (`specialSchedules`) ont priorité sur le
/// programme récurrent (`defaultSchedules`) tant qu'il y en a à venir.
List<UpcomingChurchService> upcomingChurchServices(
  ChurchProgram program, {
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);

  final specials = <UpcomingChurchService>[
    for (final entry in program.specials)
      if (entry.date != null)
        UpcomingChurchService(
          entry: entry,
          dateTime: churchProgramEntryDateTime(entry.date!, entry.time),
          isSpecial: true,
        ),
  ].where((service) => !service.dateTime.isBefore(today)).toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  if (specials.isNotEmpty) return specials;

  final services = <UpcomingChurchService>[];
  for (final entry in program.defaults) {
    final weekday = entry.weekday;
    if (weekday == null) continue;

    // Prochaine occurrence du jour hebdomadaire.
    var daysAhead = (weekday - reference.weekday) % 7;
    if (daysAhead < 0) daysAhead += 7;
    var date = DateTime(
      today.year,
      today.month,
      today.day + daysAhead,
    );
    var dateTime = churchProgramEntryDateTime(date, entry.time);
    if (!dateTime.isAfter(reference)) {
      date = date.add(const Duration(days: 7));
      dateTime = churchProgramEntryDateTime(date, entry.time);
    }

    services.add(
      UpcomingChurchService(
        entry: entry,
        dateTime: dateTime,
        isSpecial: false,
      ),
    );
  }
  services.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  return services;
}

/// Fenêtres « culte en cours » pour [day] : événements spéciaux du jour
/// + cultes récurrents dont le jour correspond.
List<(DateTime start, DateTime end)> worshipServiceWindows(
  ChurchProgram program, {
  DateTime? now,
  Duration duration = const Duration(hours: 3),
}) {
  final reference = now ?? DateTime.now();
  final day = DateTime(reference.year, reference.month, reference.day);
  final windows = <(DateTime start, DateTime end)>[];

  void add(DateTime start) {
    windows.add((start, start.add(duration)));
  }

  // Comme sur le site : les événements spéciaux remplacent le programme
  // récurrent les jours où ils ont lieu.
  for (final entry in program.specials) {
    final date = entry.date;
    if (date == null) continue;
    if (date.year == day.year &&
        date.month == day.month &&
        date.day == day.day) {
      add(churchProgramEntryDateTime(day, entry.time));
    }
  }
  if (windows.isNotEmpty) return windows;

  for (final entry in program.defaults) {
    if (entry.weekday == day.weekday) {
      add(churchProgramEntryDateTime(day, entry.time));
    }
  }
  return windows;
}

/// Combine [date] avec une heure « HH:MM » du programme.
DateTime churchProgramEntryDateTime(DateTime date, String time) {
  final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(time.trim());
  if (match == null) return date;
  final hour = int.tryParse(match.group(1)!) ?? 0;
  final minute = int.tryParse(match.group(2)!) ?? 0;
  return DateTime(date.year, date.month, date.day, hour, minute);
}
