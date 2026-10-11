import 'package:flutter_test/flutter_test.dart';
import 'package:shekinah_live/core/utils/version_utils.dart';

void main() {
  group('VersionUtils.compare', () {
    test('orders semantic versions', () {
      expect(VersionUtils.compare('1.0.0', '1.0.1'), lessThan(0));
      expect(VersionUtils.compare('1.0.1', '1.0.0'), greaterThan(0));
      expect(VersionUtils.compare('1.0.2', '1.0.2'), 0);
      expect(VersionUtils.compare('2.0.0', '1.9.9'), greaterThan(0));
    });

    test('compares build suffix when semantic version is equal', () {
      expect(VersionUtils.compare('1.0.2+9', '1.0.2+10'), lessThan(0));
      expect(VersionUtils.compare('1.0.2+10', '1.0.2+9'), greaterThan(0));
      expect(VersionUtils.compare('1.0.2+9', '1.0.2'), greaterThan(0));
      expect(VersionUtils.compare('1.0.2+9', '1.0.3+1'), lessThan(0));
    });

    test('pads missing segments with zero', () {
      expect(VersionUtils.compare('1.0', '1.0.0'), 0);
      expect(VersionUtils.compare('1', '1.0.0'), 0);
    });
  });

  group('VersionUtils.isLower', () {
    test('returns true only when strictly lower', () {
      expect(VersionUtils.isLower('1.0.1', '1.0.2'), isTrue);
      expect(VersionUtils.isLower('1.0.2', '1.0.2'), isFalse);
      expect(VersionUtils.isLower('1.0.3', '1.0.2'), isFalse);
    });
  });
}
