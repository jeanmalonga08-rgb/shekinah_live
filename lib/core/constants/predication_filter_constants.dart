/// Valeurs brutes des filtres prédications (table Supabase `sermon-archives`).
abstract final class PredicationFilterConstants {
  static const all = 'all';

  static const types = [
    'GENERAL',
    'PARENTMEETING',
    'SUNDAYSCHOOL',
    'PRAYERMEETING',
    'SPECIALMEETING',
    'YOUNTHMEETING',
  ];

  static const timeTypes = ['AM', 'PM', 'PMAM'];
}
