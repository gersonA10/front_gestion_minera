import 'package:get_it/get_it.dart';
import 'data/datasource/surveillance_datasource.dart';
import 'data/repositories/surveillance_repository_impl.dart';
import 'domain/repositories/surveillance_repository.dart';
import 'presentation/bloc/surveillance_bloc.dart';

void initSurveillanceContainer(GetIt getIt) {
  // Datasource
  getIt.registerLazySingleton(() => SurveillanceDatasource(apiClient: getIt()));

  // Repository
  getIt.registerFactory<SurveillanceRepository>(
    () => SurveillanceRepositoryImpl(datasource: getIt()),
  );

  // Bloc
  getIt.registerFactory(() => SurveillanceBloc(repository: getIt()));
}