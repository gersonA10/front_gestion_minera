import '../entity/entity.dart';

abstract class LoanRegisterRequestRepository {
  Future<LoanRegisterResponseEntity> loanRegister(LoanRequestEntity request);
}
