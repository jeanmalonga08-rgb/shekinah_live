import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/church_program.dart';

abstract class ChurchProgramRemoteDataSource {
  Future<ChurchProgram> fetchProgram({bool forceRefresh = false});

  void clearCache();
}

class ChurchProgramRemoteDataSourceImpl
    implements ChurchProgramRemoteDataSource {
  ChurchProgramRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  ChurchProgram? _cache;

  static const _weekdayByDayName = {
    'lundi': DateTime.monday,
    'mardi': DateTime.tuesday,
    'mercredi': DateTime.wednesday,
    'jeudi': DateTime.thursday,
    'vendredi': DateTime.friday,
    'samedi': DateTime.saturday,
    'dimanche': DateTime.sunday,
  };

  @override
  Future<ChurchProgram> fetchProgram({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) {
      return _cache!;
    }

    // Même endpoint REST que le site (PostgREST, clé anon publique).
    final response = await dio.get<dynamic>(
      AppConstants.churchProgramDataUrl,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'apikey': AppConstants.churchProgramSupabaseKey,
          'Authorization': 'Bearer ${AppConstants.churchProgramSupabaseKey}',
        },
        connectTimeout:
            Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      ),
    );

    final rows = response.data;
    if (rows is! List || rows.isEmpty) {
      throw const FormatException('Programme des cultes indisponible');
    }

    // Le site utilise la première ligne de la table.
    final row = rows.first;
    if (row is! Map) {
      throw const FormatException('Programme des cultes invalide');
    }
    final map = Map<String, dynamic>.from(row);

    final program = ChurchProgram(
      defaults: _parseEntries(map['defaultSchedules']),
      specials: _parseEntries(map['specialSchedules']),
    );

    _cache = program;
    return program;
  }

  @override
  void clearCache() {
    _cache = null;
  }

  List<ChurchProgramEntry> _parseEntries(Object? raw) {
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is Map) _parseEntry(Map<String, dynamic>.from(item)),
    ];
  }

  ChurchProgramEntry _parseEntry(Map<String, dynamic> map) {
    final dayName = _asString(map['day']);
    final time = _asString(map['hour']);
    final period = _asString(map['time']).toUpperCase();
    final label = _asString(map['label']);
    final date = _parseDate(_asString(map['date']));

    return ChurchProgramEntry(
      dayName: dayName,
      weekday: _weekdayByDayName[dayName.toLowerCase()],
      date: date,
      time: time,
      period: period,
      label: label.isEmpty ? null : label,
    );
  }

  static DateTime? _parseDate(String value) {
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static String _asString(Object? value) => value?.toString().trim() ?? '';
}
