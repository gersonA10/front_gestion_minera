import 'package:front_gestion_minera/modules/surveillance/presentation/bloc/surveillance_bloc.dart';
import 'package:get_it/get_it.dart';

import 'data/datasource/datasource.dart';
import 'data/repositories/repositories_impl.dart';
import 'domain/repositories/repository.dart';

void initSurveillanceContainer(GetIt getIt) {
  getIt.registerLazySingleton(
    () => SurveillanceDatasources(apiClient: getIt()),
  );

  // Repository
  getIt.registerFactory<SurveillanceRepositories>(
    () => SurveillanceRepositoriesImpl(datasources: getIt()),
  );

  // Bloc
  getIt.registerFactory(() => SurveillanceBloc(repository: getIt()));
}
