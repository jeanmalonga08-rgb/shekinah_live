import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';
import '../../data/services/live_vimeo_embed_resolver.dart';

final liveVimeoEmbedResolverProvider = Provider<LiveVimeoEmbedResolver>((ref) {
  return LiveVimeoEmbedResolver(dio: ref.watch(dioProvider));
});
