import 'package:get_it/get_it.dart';

import 'data/datasource/member_loans_datasource.dart';
import 'data/repositories/member_loans_repository_impl.dart';
import 'domain/repositories/member_loans_repository.dart';
import 'presentation/bloc/member_loan_detail_bloc.dart';
import 'presentation/bloc/member_loans_list_bloc.dart';
import 'presentation/bloc/member_loans_report_bloc.dart';

void initMemberLoansContainer(GetIt getIt) {
  // Datasource
  getIt.registerLazySingleton(
    () => MemberLoansDatasource(apiClient: getIt()),
  );

  // Repository
  getIt.registerFactory<MemberLoansRepository>(
    () => MemberLoansRepositoryImpl(datasource: getIt()),
  );

  // Blocs (uno por pantalla)
  getIt.registerFactory(() => MemberLoansListBloc(repository: getIt()));
  getIt.registerFactory(() => MemberLoanDetailBloc(repository: getIt()));
  getIt.registerFactory(() => MemberLoansReportBloc(repository: getIt()));
}
