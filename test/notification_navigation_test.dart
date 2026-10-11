import 'package:flutter_test/flutter_test.dart';
import 'package:shekinah_live/presentation/navigation/notification_navigation.dart';

void main() {
  group('resolvePushNotificationRoute', () {
    test('opens the live route from a live-started push', () {
      expect(
        resolvePushNotificationRoute({'type': 'live_started'}),
        '/live',
      );
    });

    test('uses the route supplied by the push payload', () {
      expect(
        resolvePushNotificationRoute({'route': '/live'}),
        '/live',
      );
    });

    test('falls back to the destination for each known notification type', () {
      final cases = <Map<String, dynamic>, String>{
        {'type': 'live_ended'}: '/live',
        {'type': 'AppUpdateAvailable'}: '/app-update',
        {'type': 'AudioConversionReady'}: '/offline',
        {'type': 'LibraryNew'}: '/library',
        {'type': 'PredicationNew', 'ref_id': 'sermon-1'}:
            '/predications/sermon-1',
        {'ref_type': 'cantique', 'ref_id': 'song-1'}: '/cantiques/song-1',
        {'type': 'CommuniqueNew'}: '/a-la-lune',
      };

      for (final entry in cases.entries) {
        expect(resolvePushNotificationRoute(entry.key), entry.value);
      }
    });

    test('treats the root placeholder as no specific route', () {
      expect(
        resolvePushNotificationRoute({'route': '/', 'type': 'General'}),
        isNull,
      );
    });
  });
}