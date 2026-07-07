import '../entity/cash_register_entity.dart';
import '../entity/member_loan_detail_entity.dart';
import '../entity/member_loan_list_entity.dart';
import '../entity/member_loan_report_entity.dart';

abstract class MemberLoansRepository {
  Future<MemberLoanPageEntity> getLoans({
    String? status,
    String? loanType,
    String? search,
    String? period,
    String? exactDate,
    int page,
    int limit,
  });

  Future<MemberLoanDetailEntity> getDetail(String loanId);

  Future<String> approve(String loanId, {String? cashRegisterId});

  Future<String> reject(String loanId, String reason);

  Future<String> cancel(String loanId, String reason);

  Future<String> registerPayment(
    String loanId, {
    required String paymentType,
    double? amount,
    String? periodId,
    String? cashRegisterId,
    String? paidAt,
    String? notes,
    String? comprobantePath,
  });

  Future<MemberLoanReportEntity> getReport({String? period, String? exactDate});

  Future<List<CashRegisterEntity>> getCashRegisters();
}
