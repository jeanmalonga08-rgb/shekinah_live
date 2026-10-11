import '../../domain/entities/offline_media.dart';

bool isOfflineWilliamBranhamPredication(OfflineMediaItem item) {
  if (item.category != OfflineMediaCategory.predication) return false;
  final subtitle = item.subtitle.trim();
  final separator = subtitle.indexOf('·');
  final preacher = (separator < 0 ? subtitle : subtitle.substring(0, separator))
      .trim();
  return preacher.toLowerCase().contains('branham');
}

Map<String, List<OfflineMediaItem>> groupOfflinePredications(
  Iterable<OfflineMediaItem> items, {
  required String unknownPreacherLabel,
}) {
  final groups = <String, List<OfflineMediaItem>>{};
  for (final item in items) {
    final subtitle = item.subtitle.trim();
    final separator = subtitle.indexOf('·');
    final preacher = (separator < 0 ? subtitle : subtitle.substring(0, separator))
        .trim();
    final group = preacher.isEmpty ? unknownPreacherLabel : preacher;
    groups.putIfAbsent(group, () => []).add(item);
  }

  final sortedKeys = groups.keys.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return {
    for (final key in sortedKeys) key: groups[key]!,
  };
}