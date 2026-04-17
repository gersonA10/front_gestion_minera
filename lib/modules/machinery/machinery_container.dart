import 'package:front_gestion_minera/modules/machinery/data/datasource/machinery_datasource.dart';
import 'package:front_gestion_minera/modules/machinery/data/repositories/machinary_repository_impl.dart';
import 'package:front_gestion_minera/modules/machinery/domain/repositories/repository.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/bloc/machinery_bloc.dart';
import 'package:get_it/get_it.dart';

void initMachineryContainer(GetIt getIt) {
  //Datasource
  getIt.registerLazySingleton(() =>  MachineryDatasource(apiClient: getIt()));

  //Repository
  getIt.registerCachedFactory<MachineryRepository>(() => MachineryRepositoryImpl(datasource: getIt()));

  //bloc
  getIt.registerFactory(() => MachineryBloc(repository: getIt()));
}