import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/audio_conversion_api_service.dart';
import 'notifications_api_provider.dart';

final audioConversionApiServiceProvider = Provider<AudioConversionApiService>(
  (ref) => AudioConversionApiService(
    dio: ref.watch(notificationsApiDioProvider),
  ),
);
