import 'package:get_it/get_it.dart';

import 'data/datasource/staff_datasource.dart';
import 'data/repositories/staff_repository_impl.dart';
import 'domain/repositories/staff_repository.dart';
import 'presentation/bloc/staff_bloc.dart';

void initStaffContainer(GetIt getIt) {
  getIt.registerLazySingleton(
    () => StaffDatasource(apiClient: getIt()),
  );

  getIt.registerFactory<StaffRepository>(
    () => StaffRepositoryImpl(datasource: getIt()),
  );

  getIt.registerFactory(() => StaffBloc(repository: getIt()));
}
