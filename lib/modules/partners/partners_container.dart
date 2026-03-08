import 'package:front_gestion_minera/modules/partners/data/datasource/money_request_datasource.dart';
import 'package:front_gestion_minera/modules/partners/data/repositories/loan_history_repository_impl.dart';
import 'package:front_gestion_minera/modules/partners/data/repositories/loan_register_request_repository_impl.dart';
import 'package:front_gestion_minera/modules/partners/data/repositories/money_request_repository_impl.dart';
import 'package:front_gestion_minera/modules/partners/data/repositories/partners_repository_impl.dart';
import 'package:front_gestion_minera/modules/partners/domain/repositories/money_request_repository.dart';
import 'package:front_gestion_minera/modules/partners/presentation/bloc/partners_bloc.dart';
import 'package:get_it/get_it.dart';

import 'data/datasource/datasource.dart';
import 'domain/repositories/repository.dart';

void initPartnersContainer(GetIt getIt) {
  // Inyectamos el ApiClient que viene de injector _container
  getIt.registerLazySingleton(() => PartnersDatasource(apiClient: getIt()));
  getIt.registerLazySingleton(() => MoneyRequestDatasource(apiClient: getIt()));
  getIt.registerLazySingleton(
    () => LoanRegisterRequestDatasource(apiClient: getIt()),
  );
  getIt.registerLazySingleton(() => LoanHistoryDatasource(apiClient: getIt()));

  // Repository
  getIt.registerFactory<PartnersRepository>(
    () => PartnersRepositoryImpl(datasource: getIt()),
  );
  getIt.registerFactory<MoneyRequestRepository>(
    () => MoneyRequestRepositoryImpl(datasource: getIt()),
  );
  getIt.registerFactory<LoanRegisterRequestRepository>(
    () => LoanRegisterRequestRepositoryImpl(datasource: getIt()),
  );
  getIt.registerFactory<LoanHistoryRepository>(
    () => LoanHistoryRepositoryImpl(datasource: getIt()),
  );

  // Bloc
  getIt.registerFactory(
    () => PartnersBloc(
      repository: getIt(),
      moneyRepository: getIt(),
      loanHistoryRepository: getIt(),
      loanRegisterRequestRepository: getIt(),
    ),
  );
}
