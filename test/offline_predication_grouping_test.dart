import 'package:flutter_test/flutter_test.dart';
import 'package:shekinah_live/domain/entities/offline_media.dart';
import 'package:shekinah_live/presentation/utils/offline_predication_grouping.dart';

void main() {
  test('groups by preacher, strips Branham codes, and sorts groups', () {
    final items = [
      _item('branham_b', 'William Branham · FRN 47-0412'),
      _item('alpha', 'A. Preacher · Sermon 1'),
      _item('branham_a', 'William Branham · FRN 47-0413'),
      _item('beta', 'B. Preacher'),
    ];

    final groups = groupOfflinePredications(
      items,
      unknownPreacherLabel: 'Unknown preacher',
    );

    expect(groups.keys, ['A. Preacher', 'B. Preacher', 'William Branham']);
    expect(groups['William Branham']!.map((item) => item.id), [
      'branham_b',
      'branham_a',
    ]);
    expect(groups.values.expand((group) => group), hasLength(items.length));
  });

  test('keeps media without preacher metadata in a fallback group', () {
    final groups = groupOfflinePredications(
      [_item('empty', ''), _item('separators', ' · code')],
      unknownPreacherLabel: 'Unknown preacher',
    );

    expect(groups.keys, ['Unknown preacher']);
    expect(groups.values.single.map((item) => item.id), ['empty', 'separators']);
  });

  test('detects Branham sermons for their offline thumbnail', () {
    expect(
      isOfflineWilliamBranhamPredication(
        _item('branham', 'William Branham · FRN 47-0412'),
      ),
      isTrue,
    );
    expect(
      isOfflineWilliamBranhamPredication(
        _item('other', 'Autre prédicateur'),
      ),
      isFalse,
    );
  });
}

OfflineMediaItem _item(String id, String subtitle) => OfflineMediaItem(
      id: id,
      category: OfflineMediaCategory.predication,
      format: OfflineMediaFormat.audio,
      sourceId: id,
      title: id,
      subtitle: subtitle,
      localPath: 'test/$id.m4a',
      fileSizeBytes: 1,
      downloadedAt: DateTime(2026),
    );