import 'package:front_gestion_minera/modules/partners/data/datasource/money_request_datasource.dart';
import 'package:front_gestion_minera/modules/partners/data/repositories/money_request_repository_impl.dart';
import 'package:front_gestion_minera/modules/partners/domain/repositories/money_request_repository.dart';
import 'package:front_gestion_minera/modules/partners/presentation/bloc/partners_bloc.dart';
import 'package:get_it/get_it.dart';

void initPartnersContainer(GetIt getIt) {
  //datasource
  getIt.registerLazySingleton(() => MoneyRequestDatasource(apiClient: getIt()));
  // Repository
  getIt.registerFactory<MoneyRequestRepository>(
    () => MoneyRequestRepositoryImpl(datasource: getIt()),
  );
  // Bloc
  getIt.registerFactory(
    () => PartnersBloc(
      repository: getIt(),
      moneyRepository: getIt(),
      loanHistoryRepository: getIt(),
    ),
  );
}
