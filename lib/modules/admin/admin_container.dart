import 'package:get_it/get_it.dart';

import 'data/datasource/admin_datasource.dart';
import 'data/repositories/admin_repository_impl.dart';
import 'domain/repositories/admin_repository.dart';
import 'presentation/bloc/admin_bloc.dart';

void initAdminContainer(GetIt getIt) {
  // Datasource
  getIt.registerLazySingleton(() => AdminDatasource(apiClient: getIt()));

  // Repository
  getIt.registerFactory<AdminRepository>(
    () => AdminRepositoryImpl(datasource: getIt()),
  );

  // Bloc
  getIt.registerFactory(() => AdminBloc(repository: getIt()));
}
