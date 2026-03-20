import 'package:front_gestion_minera/modules/treasury/data/datasource/treasury_datasource.dart';
import 'package:front_gestion_minera/modules/treasury/data/repositories/treasury_repository_impl.dart';
import 'package:front_gestion_minera/modules/treasury/domain/repositories/treasury_repository.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:get_it/get_it.dart';


void initTreasuryContainer(GetIt getIt) {
  // Datasource
  getIt.registerLazySingleton(() => TreasuryDatasource(apiClient: getIt()));

  // Repository
  getIt.registerFactory<TreasuryRepository>(
    () => TreasuryRepositoryImpl(datasource: getIt()),
  );

  // Bloc
  getIt.registerFactory(() => TreasuryBloc(repository: getIt()));
}
