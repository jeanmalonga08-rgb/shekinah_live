import '../../domain/entities/church_program.dart';
import 'church_program_schedule.dart';

String formatLiveDuration(Duration duration) {
  final safe = duration.isNegative ? Duration.zero : duration;
  final days = safe.inDays;
  final hours = safe.inHours.remainder(24);
  final minutes = safe.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = safe.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (days > 0) {
    return '${days}d ${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
  }
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}

Duration liveElapsedSince(DateTime? startedAt) {
  if (startedAt == null) return Duration.zero;
  return DateTime.now().difference(startedAt);
}

/// Temps ecoule depuis le dernier culte prevu aujourd'hui ou hier a Kinshasa.
/// En absence de programme, utilise l'horodatage disponible du direct.
Duration liveWorshipElapsed(
  ChurchProgram? program,
  DateTime? liveStartedAt, {
  DateTime? now,
}) {
  final instant = now ?? DateTime.now();
  final reference = kinshasaTime(instant);
  if (program != null) {
    final windows = [
      ...worshipServiceWindows(program, now: instant),
      ...worshipServiceWindows(
        program,
        now: instant.subtract(const Duration(days: 1)),
      ),
    ];
    final starts =
        windows
            .map((window) => window.$1)
            .where((start) => !start.isAfter(reference))
            .toList()
          ..sort((a, b) => b.compareTo(a));
    if (starts.isNotEmpty) return reference.difference(starts.first);
  }
  return liveStartedAt == null
      ? Duration.zero
      : instant.difference(liveStartedAt);
}
