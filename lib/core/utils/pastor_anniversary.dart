/// Photo « 70 ans du Pasteur » affichée à partir du 10 novembre
/// jusqu'à la fin du mois de novembre 2026.
class PastorAnniversary {
  PastorAnniversary._();

  static const String imageUrl =
      'https://shekinahgospel.org/images/pastor-70-anniversary.png';
  static final DateTime start = DateTime(2026, 11, 10);
  static final DateTime end = DateTime(2026, 12, 1);

  static bool get isActive {
    final now = DateTime.now();
    return !now.isBefore(start) && now.isBefore(end);
  }
}
