import '../../l10n/app_localizations.dart';

class NextWorshipService {
  const NextWorshipService({
    required this.weekday,
    required this.dateTime,
    required this.remaining,
  });

  final int weekday;
  final DateTime dateTime;
  final Duration remaining;

  String dayLabel(AppLocalizations l10n) {
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

  static const _schedule = [
    (weekday: DateTime.sunday, hour: 9, minute: 30),
    (weekday: DateTime.wednesday, hour: 17, minute: 0),
    (weekday: DateTime.thursday, hour: 17, minute: 0),
  ];

  /// Durée estimée d'un culte (fenêtre « heures de culte »).
  static const Duration worshipServiceDuration = Duration(hours: 3);

  /// `true` si [now] tombe dans une plage horaire de culte régulier.
  static bool isDuringWorshipService([DateTime? now]) {
    final reference = now ?? DateTime.now();
    for (final slot in _schedule) {
      if (reference.weekday != slot.weekday) continue;
      final start = DateTime(
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

  static NextWorshipService compute([DateTime? now]) {
    final reference = now ?? DateTime.now();

    DateTime? nearest;
    var weekday = DateTime.sunday;

    for (final slot in _schedule) {
      var candidate = DateTime(
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
