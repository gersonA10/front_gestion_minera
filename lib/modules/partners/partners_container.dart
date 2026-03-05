import 'package:front_gestion_minera/modules/partners/data/repositories/partners_repository_impl.dart';
import 'package:front_gestion_minera/modules/partners/presentation/bloc/partners_bloc.dart';
import 'package:get_it/get_it.dart';

import 'data/datasource/datasource.dart';
import 'domain/repositories/repository.dart';

void initPartnersContainer(GetIt getIt) {
  // Inyectamos el ApiClient que viene de injector _container
  getIt.registerLazySingleton(() => PartnersDatasource(apiClient: getIt()));

  // Repository
  getIt.registerFactory<PartnersRepository>(
    () => PartnersRepositoryImpl(datasource: getIt()),
  );

  // Bloc
  getIt.registerFactory(() => PartnersBloc(repository: getIt()));
}
