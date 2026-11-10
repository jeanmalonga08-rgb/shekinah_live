import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_provider.dart';
import '../../data/datasources/church_program_remote_datasource.dart';
import '../../domain/entities/church_program.dart';

export '../../core/utils/church_program_schedule.dart';

final churchProgramDataSourceProvider =
    Provider<ChurchProgramRemoteDataSource>(
  (ref) => ChurchProgramRemoteDataSourceImpl(dio: ref.watch(dioProvider)),
);

final churchProgramProvider = FutureProvider<ChurchProgram>((ref) async {
  final dataSource = ref.watch(churchProgramDataSourceProvider);
  return dataSource.fetchProgram();
});
