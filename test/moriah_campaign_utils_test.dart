import 'package:flutter_test/flutter_test.dart';
import 'package:shekinah_live/core/utils/moriah_campaign_utils.dart';

void main() {
  const sampleJs = '''
    widgetTitle:`PROJET RECONSTRUCTION`,
    widgetActiveTag:`Campagne Active`,
    var Ce=new Date(`2026-09-24T23:59:59`);
  ''';

  group('MoriahCampaignUtils.parseCampaignEndDate', () {
    test('parses end date from donation bundle', () {
      final end = MoriahCampaignUtils.parseCampaignEndDate(sampleJs);
      expect(end, DateTime.parse('2026-09-24T23:59:59'));
    });
  });

  group('MoriahCampaignUtils.isCampaignActive', () {
    test('true before campaign end with active badge', () {
      expect(
        MoriahCampaignUtils.isCampaignActive(
          sampleJs,
          now: DateTime.parse('2026-09-07T12:00:00'),
        ),
        isTrue,
      );
    });

    test('false after campaign end', () {
      expect(
        MoriahCampaignUtils.isCampaignActive(
          sampleJs,
          now: DateTime.parse('2026-09-25T00:00:00'),
        ),
        isFalse,
      );
    });

    test('false when active badge removed from site', () {
      expect(
        MoriahCampaignUtils.isCampaignActive(
          'widgetTitle:`PROJET RECONSTRUCTION`',
          now: DateTime.parse('2026-09-07T12:00:00'),
        ),
        isFalse,
      );
    });
  });
}
