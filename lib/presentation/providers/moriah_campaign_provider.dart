import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/moriah_campaign_remote_datasource.dart';

final moriahCampaignRemoteDataSourceProvider =
    Provider<MoriahCampaignRemoteDataSource>(
  (ref) => MoriahCampaignRemoteDataSourceImpl(),
);

/// `true` si la campagne reconstruction est active sur donation.shekinahgospel.org.
final moriahCampaignActiveProvider = FutureProvider<bool>((ref) async {
  return ref.watch(moriahCampaignRemoteDataSourceProvider).fetchIsCampaignActive();
});
