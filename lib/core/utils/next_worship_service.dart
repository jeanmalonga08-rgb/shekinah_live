import '../../domain/entities/church_program.dart';
import '../../l10n/app_localizations.dart';
import '../l10n/entity_labels.dart';
import '../l10n/locale_format.dart';
import 'church_program_schedule.dart';

class NextWorshipService {
  const NextWorshipService({
    required this.weekday,
    required this.dateTime,
    required this.remaining,
    this.eventLabel,
    this.timeText,
    this.period,
  });

  final int weekday;
  final DateTime dateTime;
  final Duration remaining;

  /// Libellé d'un événement ponctuel (ex. « Réunion de Thanksgiving »).
  final String? eventLabel;

  /// Heure « HH:MM » venant du programme en ligne.
  final String? timeText;

  /// Moment de la journée : `AM`, `PM` ou `PMAM` (veillée).
  final String? period;

  String dayLabel(AppLocalizations l10n) {
    if (eventLabel != null && eventLabel!.isNotEmpty) {
      return eventLabel!;
    }
    if (timeText != null && timeText!.isNotEmpty) {
      return formatWeekdayName(dateTime, l10n.localeName);
    }
    switch (weekday) {
      case DateTime.sunday:
        return l10n.worshipSunday;
      case DateTime.wednesday:
        return l10n.worshipWednesday;
      case DateTime.thursday:
        return l10n.worshipThursday;
      default:
        return l10n.worshipSunday;
    }
  }

  String timeLabel(AppLocalizations l10n) {
    if (timeText != null && timeText!.isNotEmpty) {
      final periodLabel = worshipPeriodLabel(l10n, period);
      return periodLabel == null ? timeText! : '$timeText · $periodLabel';
    }
    switch (weekday) {
      case DateTime.sunday:
        return l10n.worshipTimeSunday;
      case DateTime.wednesday:
      case DateTime.thursday:
        return l10n.worshipTimeEvening;
      default:
        return l10n.worshipTimeSunday;
    }
  }

  String countdownLabel(AppLocalizations l10n) {
    final total = remaining.inSeconds;
    if (total <= 0) return l10n.countdownNow;

    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;
    final hoursText = hours.toString().padLeft(2, '0');
    final minutesText = minutes.toString().padLeft(2, '0');
    final secondsText = seconds.toString().padLeft(2, '0');

    if (days > 0) {
      return l10n.countdownWithDays(days, hoursText, minutesText);
    }
    if (hours > 0) {
      return l10n.countdownWithHours(hoursText, minutesText, secondsText);
    }
    return l10n.countdownMinutesOnly(minutesText, secondsText);
  }

  String chronoLabel(AppLocalizations l10n) {
    final safe = remaining.isNegative ? Duration.zero : remaining;
    final days = safe.inDays;
    final hours = (safe.inHours % 24).toString().padLeft(2, '0');
    final minutes = (safe.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (safe.inSeconds % 60).toString().padLeft(2, '0');
    final clock = '$hours:$minutes:$seconds';
    if (days > 0) return l10n.countdownChronoWithDays(days, clock);
    if (safe.inSeconds <= 0) return '00:00:00';
    return clock;
  }

  /// Programme statique de secours (utilisé hors ligne ou si [program]
  /// est null).
  static const _schedule = [
    (weekday: DateTime.sunday, hour: 9, minute: 30),
    (weekday: DateTime.wednesday, hour: 17, minute: 0),
    (weekday: DateTime.thursday, hour: 17, minute: 0),
  ];

  /// Durée estimée d'un culte (fenêtre « heures de culte »).
  static const Duration worshipServiceDuration = Duration(hours: 3);

  /// `true` si [now] tombe dans une plage horaire de culte.
  /// Avec [program], utilise le programme publié sur shekinahgospel.org ;
  /// sinon replie sur l'horaire statique.
  static bool isDuringWorshipService({DateTime? now, ChurchProgram? program}) {
    final instant = now ?? DateTime.now();
    final reference = kinshasaTime(instant);

    if (program != null) {
      for (final window in worshipServiceWindows(program, now: instant)) {
        if (!reference.isBefore(window.$1) && reference.isBefore(window.$2)) {
          return true;
        }
      }
      return false;
    }

    for (final slot in _schedule) {
      if (reference.weekday != slot.weekday) continue;
      final start = DateTime.utc(
        reference.year,
        reference.month,
        reference.day,
        slot.hour,
        slot.minute,
      );
      final end = start.add(worshipServiceDuration);
      if (!reference.isBefore(start) && reference.isBefore(end)) {
        return true;
      }
    }
    return false;
  }

  /// Prochain culte. Avec [program], reflète le programme en ligne
  /// (événements spéciaux prioritaires) ; sinon horaire statique.
  static NextWorshipService compute({ChurchProgram? program, DateTime? now}) {
    final instant = now ?? DateTime.now();
    final reference = kinshasaTime(instant);

    if (program != null) {
      // Ne cibler que les services strictement à venir : un événement
      // spécial plus tôt aujourd'hui resterait sinon collé à 00:00:00.
      var services = upcomingChurchServices(
        program,
        now: instant,
      ).where((service) => service.dateTime.isAfter(reference)).toList();
      if (services.isEmpty) {
        // Tous les événements spéciaux sont passés : revenir au récurrent.
        services = upcomingChurchServices(
          ChurchProgram(defaults: program.defaults, specials: const []),
          now: instant,
        ).where((service) => service.dateTime.isAfter(reference)).toList();
      }
      if (services.isNotEmpty) {
        final first = services.first;
        return NextWorshipService(
          weekday: first.dateTime.weekday,
          dateTime: first.dateTime,
          remaining: first.dateTime.difference(reference),
          eventLabel: first.isSpecial ? first.entry.label : null,
          timeText: first.entry.time,
          period: first.entry.period,
        );
      }
    }

    DateTime? nearest;
    var weekday = DateTime.sunday;

    for (final slot in _schedule) {
      var candidate = DateTime.utc(
        reference.year,
        reference.month,
        reference.day,
        slot.hour,
        slot.minute,
      );

      var daysAhead = (slot.weekday - reference.weekday) % 7;
      if (daysAhead < 0) daysAhead += 7;
      if (daysAhead == 0 && !candidate.isAfter(reference)) {
        daysAhead = 7;
      }
      candidate = candidate.add(Duration(days: daysAhead));

      if (nearest == null || candidate.isBefore(nearest)) {
        nearest = candidate;
        weekday = slot.weekday;
      }
    }

    final next = nearest ?? reference.add(const Duration(days: 1));
    return NextWorshipService(
      weekday: weekday,
      dateTime: next,
      remaining: next.difference(reference),
    );
  }
}
