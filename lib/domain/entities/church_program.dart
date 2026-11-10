/// Programme des cultes tel que publié sur shekinahgospel.org
/// (table Supabase `services-live`).
class ChurchProgramEntry {
  const ChurchProgramEntry({
    required this.dayName,
    this.weekday,
    this.date,
    this.time = '',
    this.period = '',
    this.label,
  });

  /// Nom du jour fourni par le site (ex. « Dimanche », « Mercredi »).
  final String dayName;

  /// `DateTime.weekday` (1 = lundi … 7 = dimanche), null si inconnu.
  final int? weekday;

  /// Date pour les événements ponctuels (`specialSchedules`).
  final DateTime? date;

  /// Heure au format 24 h « HH:MM » (ex. « 09:30 », « 17:00 »).
  final String time;

  /// Moment de la journée : `AM`, `PM` ou `PMAM` (veillée).
  final String period;

  /// Libellé de l'événement (ex. « Réunion de Thanksgiving »).
  final String? label;
}

class ChurchProgram {
  const ChurchProgram({
    required this.defaults,
    required this.specials,
  });

  /// Cultes récurrents hebdomadaires (`defaultSchedules`).
  final List<ChurchProgramEntry> defaults;

  /// Événements ponctuels (`specialSchedules`).
  final List<ChurchProgramEntry> specials;
}
