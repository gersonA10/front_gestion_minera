import 'package:front_gestion_minera/modules/auth/data/datasource/auth_datasource.dart';
import 'package:front_gestion_minera/modules/auth/data/repositories/auth_repository_impl.dart';
import 'package:front_gestion_minera/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';

import 'domain/repositories/repository.dart';

void initAuthContainer(GetIt getIt) {
  //var apiClient = ApiClient();
  //Datasource
  getIt.registerLazySingleton(() => AuthDatasource());
  //repository
  getIt.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(datasource: getIt()),
  );
  //Bloc
  getIt.registerFactory(() => AuthBloc(repository: getIt()));
}
