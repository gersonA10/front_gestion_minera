import 'package:get_it/get_it.dart';

import 'data/datasource/minutes_memos_datasource.dart';
import 'data/repositories/minutes_memos_repository_impl.dart';
import 'domain/repositories/minutes_memos_repository.dart';
import 'presentation/bloc/minutes_memos_bloc.dart';

void initMinutesMemosContainer(GetIt getIt) {
  getIt.registerLazySingleton(
    () => MinutesMemosDatasource(apiClient: getIt()),
  );

  getIt.registerFactory<MinutesMemosRepository>(
    () => MinutesMemosRepositoryImpl(datasource: getIt()),
  );

  getIt.registerFactory(() => MinutesMemosBloc(repository: getIt()));
}
