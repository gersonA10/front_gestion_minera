import 'package:front_gestion_minera/modules/auth/data/datasource/auth_datasource.dart';
import 'package:front_gestion_minera/modules/auth/data/repositories/auth_repository_impl.dart';
import 'package:front_gestion_minera/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';

import 'domain/repositories/repository.dart';

void initAuthContainer(GetIt getIt) {
  // Inyectamos el ApiClient que viene de injector _container
  getIt.registerLazySingleton(() => AuthDatasource(apiClient: getIt()));
  
  // Repository
  getIt.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(datasource: getIt()),
  );
  
  // Bloc
  getIt.registerFactory(() => AuthBloc(repository: getIt()));
}