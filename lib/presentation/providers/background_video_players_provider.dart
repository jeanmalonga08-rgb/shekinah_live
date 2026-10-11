import 'package:flutter_riverpod/flutter_riverpod.dart';

/// When false, home/carousel [VideoPlayer]s must dispose so MediaCodec slots
/// are free (MediaTek often allows only 1–2 concurrent AVC decoders).
final backgroundVideoPlayersAllowedProvider =
    NotifierProvider<BackgroundVideoPlayersAllowedNotifier, bool>(
  BackgroundVideoPlayersAllowedNotifier.new,
);

class BackgroundVideoPlayersAllowedNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setAllowed(bool allowed) {
    if (state == allowed) return;
    state = allowed;
  }
}
