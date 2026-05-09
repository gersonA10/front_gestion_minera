import 'package:get_it/get_it.dart';

import 'data/datasource/home_dashboard__camp_datasource.dart';
import 'data/repositories/home_dashboard__camp_repository_impl.dart';
import 'domain/repositories/home_dashboard__camp_repository.dart';
import 'presentation/bloc/camp_bloc.dart';

void initCampContainer(GetIt getIt) {
  getIt.registerLazySingleton(() => CampDatasource(apiClient: getIt()));

  getIt.registerFactory<CampRepository>(
    () => CampRepositoryImpl(datasource: getIt()),
  );

  getIt.registerFactory(() => CampBloc(repository: getIt()));
}
