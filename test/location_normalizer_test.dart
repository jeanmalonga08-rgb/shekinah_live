import 'package:flutter_test/flutter_test.dart';
import 'package:shekinah_live/core/utils/location_normalizer.dart';

void main() {
  group('LocationNormalizer', () {
    test('regroupe les variantes Kinshasa', () {
      final normalized = LocationNormalizer.normalize([
        'Kinshasa RDC',
        'Kinshasa, RDC',
        'Kinshasa-RD',
        'Kinshasa-RDC',
        'Kinshasa-RDC Part1',
        'Kinshasa/Congo',
        'Kinshasa/R.D.Congo',
        'Kinshasa/RdCongo',
        'Kinshsa/RdCongo',
        'Righini - Kinshasa, RDC',
      ]);

      expect(normalized.labels, ['Kinshasa, RDC']);
      expect(normalized.options.single.variants.length, 10);
    });

    test('regroupe les variantes Johannesburg', () {
      final normalized = LocationNormalizer.normalize([
        'Johanesburg RSA',
        'Johannesburg RSA',
        'Johannesburg, SA',
        'Johannesburg/RSA',
        'Johannesburg/SA',
      ]);

      expect(normalized.labels, ['Johannesburg, RSA']);
      expect(normalized.options.single.variants.length, 5);
    });

    test('conserve les villes distinctes', () {
      final normalized = LocationNormalizer.normalize([
        'Kolofuma/Rd Congo',
        'Kwilu-Ngongo/Rd Congo',
        'Mvuazi/Rd Congo',
        'Lubumbashi, RDC',
        'Lubumbashi-RDC',
      ]);

      expect(normalized.labels, [
        'Kolofuma, RD Congo',
        'Kwilu-Ngongo, RD Congo',
        'Lubumbashi, RDC',
        'Mvuazi, RD Congo',
      ]);
    });

    test('variantsFor retourne toutes les variantes DB', () {
      final normalized = LocationNormalizer.normalize([
        'Vancouver, CANADA',
        'Vancouver/Canada',
      ]);

      expect(
        normalized.variantsFor('Vancouver, Canada'),
        ['Vancouver, CANADA', 'Vancouver/Canada'],
      );
    });
  });
}
