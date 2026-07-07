import 'package:front_gestion_minera/modules/admin/users/data/datasource/users_datasource.dart';
import 'package:front_gestion_minera/modules/admin/users/data/repositories/users_repository_impl.dart';
import 'package:front_gestion_minera/modules/admin/users/domain/repositories/users_repository.dart';
import 'package:front_gestion_minera/modules/admin/users/presentation/bloc/admin_users_bloc.dart';
import 'package:get_it/get_it.dart';
import 'home/data/datasource/admin_datasource.dart';
import 'home/data/repositories/admin_repository_impl.dart';
import 'home/domain/repositories/admin_repository.dart';
import 'home/presentation/bloc/admin_bloc.dart';

void initAdminContainer(GetIt getIt) {
  // Datasource
  getIt.registerLazySingleton(() => AdminDatasource(apiClient: getIt()));
  getIt.registerLazySingleton(() => UsersDatasource(apiClient: getIt()));

  // Repository
  getIt.registerFactory<AdminRepository>(
    () => AdminRepositoryImpl(datasource: getIt()),
  );
   getIt.registerFactory<UsersRepository>(
    () => UsersRepositoryImpl(datasource: getIt()),
  );

  // Bloc
  getIt.registerFactory(() => AdminBloc(repository: getIt()));
  getIt.registerLazySingleton(() => AdminUsersBloc(repository: getIt()));
}
