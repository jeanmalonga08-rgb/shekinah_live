import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/moriah_campaign_utils.dart';

abstract class MoriahCampaignRemoteDataSource {
  Future<bool> fetchIsCampaignActive();
}

class MoriahCampaignRemoteDataSourceImpl
    implements MoriahCampaignRemoteDataSource {
  MoriahCampaignRemoteDataSourceImpl({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 20),
                headers: {
                  'Accept': 'text/html,application/javascript,*/*',
                  'User-Agent': AppConstants.userAgent,
                },
                validateStatus: (status) =>
                    status != null && status >= 200 && status < 400,
              ),
            );

  final Dio _dio;

  @override
  Future<bool> fetchIsCampaignActive() async {
    try {
      final js = await _fetchDonationJs();
      if (js == null || js.isEmpty) return false;
      return MoriahCampaignUtils.isCampaignActive(js);
    } catch (_) {
      return false;
    }
  }

  Future<String?> _fetchDonationJs() async {
    final htmlResponse = await _dio.get<String>(
      AppConstants.donationUrl,
      options: Options(responseType: ResponseType.plain),
    );
    final html = htmlResponse.data ?? '';
    final scriptPath = _extractJsPath(html) ?? '/assets/index.js';
    final jsUrl = scriptPath.startsWith('http')
        ? scriptPath
        : '${AppConstants.donationUrl}$scriptPath';

    final jsResponse = await _dio.get<String>(
      jsUrl,
      options: Options(responseType: ResponseType.plain),
    );
    return jsResponse.data;
  }

  String? _extractJsPath(String html) {
    final match = RegExp(
      r'src="(/assets/index[^"]+\.js)"',
    ).firstMatch(html);
    return match?.group(1);
  }
}
