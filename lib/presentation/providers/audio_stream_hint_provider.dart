import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/next_worship_service.dart';
import '../providers/live_stream_provider.dart';

/// Masqué pour la session en cours (réapparaît au prochain lancement).
final audioStreamHintDismissedProvider = StateProvider<bool>((ref) => false);

final audioStreamHintVisibleProvider = Provider<bool>((ref) {
  if (ref.watch(audioStreamHintDismissedProvider)) return false;
  final liveState = ref.watch(liveStreamProvider);
  if (liveState.isLoading) return false;
  if (liveState.isLive) return false;
  if (NextWorshipService.isDuringWorshipService()) return false;
  final entity = liveState.liveStream;
  if (entity == null || !entity.hasAnyAudio) return false;
  return true;
});

final audioStreamHintDismissActionProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(audioStreamHintDismissedProvider.notifier).state = true;
  };
});
