import '../../domain/entity/entity.dart';
import '../../domain/repositories/repository.dart';
import '../datasource/datasource.dart';
import '../models/model.dart';

class LoanRegisterRequestRepositoryImpl extends LoanRegisterRequestRepository {
  final LoanRegisterRequestDatasource datasource;
  LoanRegisterRequestRepositoryImpl({required this.datasource});

  @override
  Future<LoanRegisterResponseEntity> loanRegister(
    LoanRequestEntity request,
  ) async {
    final requestModel = LoanRequestModel.fromEntity(request);
    final response = await datasource.loanRegisterResquest(requestModel);
    return response.toEntity();
  }
}
