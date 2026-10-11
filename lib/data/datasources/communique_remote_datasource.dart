import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/communique.dart';

abstract class CommuniqueRemoteDataSource {
  Future<List<Communique>> fetchActiveCommuniques();
}

class CommuniqueRemoteDataSourceImpl implements CommuniqueRemoteDataSource {
  final Dio dio;

  CommuniqueRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Communique>> fetchActiveCommuniques() async {
    try {
      final mainJs = await _fetchMainScript();
      final communiques = _parseCommuniques(mainJs);
      if (communiques.isNotEmpty) {
        return communiques;
      }
    } on DioException {
      // Fallback below.
    } catch (_) {
      // Fallback below.
    }

    return const [];
  }

  Future<String> _fetchMainScript() async {
    final homeResponse = await dio.get<String>(
      AppConstants.websiteUrl,
      options: Options(
        responseType: ResponseType.plain,
        headers: {'User-Agent': AppConstants.userAgent},
        connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      ),
    );

    final homeHtml = homeResponse.data ?? '';
    final scriptMatch = RegExp(r'main-[A-Z0-9]+\.js').firstMatch(homeHtml);
    if (scriptMatch == null) {
      throw Exception('Main script not found');
    }

    final scriptResponse = await dio.get<String>(
      '${AppConstants.websiteUrl}/${scriptMatch.group(0)}',
      options: Options(
        responseType: ResponseType.plain,
        headers: {'User-Agent': AppConstants.userAgent},
        connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      ),
    );

    return scriptResponse.data ?? '';
  }

  List<Communique> _parseCommuniques(String script) {
    final communiques = <Communique>[];

    for (final language in ['fr', 'en']) {
      final match = RegExp(
        '$language:\\{title:"([^"]+)",message:`((?:\\\\.|[^`])*)`,readAll:"([^"]+)"',
      ).firstMatch(script);

      if (match != null) {
        communiques.add(
          Communique(
            title: _decodeJsString(match.group(1)!),
            message: _decodeJsString(match.group(2)!),
            readMoreLabel: _decodeJsString(match.group(3)!),
            readMoreUrl: AppConstants.communiqueDetailsUrl,
            language: language,
          ),
        );
      }
    }

    return communiques;
  }

  String _decodeJsString(String value) {
    return value
        .replaceAll(r'\xE9', 'é')
        .replaceAll(r'\xE8', 'è')
        .replaceAll(r'\xEA', 'ê')
        .replaceAll(r'\xE0', 'à')
        .replaceAll(r'\xE2', 'â')
        .replaceAll(r'\xEE', 'î')
        .replaceAll(r'\xEF', 'ï')
        .replaceAll(r'\xF4', 'ô')
        .replaceAll(r'\xFB', 'û')
        .replaceAll(r'\xE7', 'ç')
        .replaceAll(r'\u2014', '—')
        .replaceAll(r"\'", "'")
        .replaceAll(r'\"', '"')
        .replaceAll(r'\\', r'\');
  }

}
