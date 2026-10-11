/// Détecte si la campagne reconstruction Moriah est active sur le site donation.
class MoriahCampaignUtils {
  MoriahCampaignUtils._();

  static final _endDatePattern = RegExp(
    r'Ce=new Date\(`([^`]+)`\)',
  );

  static DateTime? parseCampaignEndDate(String js) {
    final match = _endDatePattern.firstMatch(js);
    if (match == null) return null;
    return DateTime.tryParse(match.group(1)!);
  }

  /// Aligné sur [donation.shekinahgospel.org](https://donation.shekinahgospel.org/) :
  /// widget « PROJET RECONSTRUCTION » + badge « Campagne Active » + date de fin future.
  static bool isCampaignActive(String js, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final hasReconstructionProject = js.contains('PROJET RECONSTRUCTION') ||
        js.contains('RECONSTRUCTION PROJECT');
    final hasActiveBadge = js.contains('Campagne Active') ||
        js.contains('Active Campaign');

    if (!hasReconstructionProject || !hasActiveBadge) return false;

    final endDate = parseCampaignEndDate(js);
    if (endDate == null) return true;
    return reference.isBefore(endDate);
  }
}
