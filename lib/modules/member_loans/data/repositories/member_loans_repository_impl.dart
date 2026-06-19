import '../../domain/entity/cash_register_entity.dart';
import '../../domain/entity/member_loan_detail_entity.dart';
import '../../domain/entity/member_loan_list_entity.dart';
import '../../domain/entity/member_loan_report_entity.dart';
import '../../domain/repositories/member_loans_repository.dart';
import '../datasource/member_loans_datasource.dart';

class MemberLoansRepositoryImpl extends MemberLoansRepository {
  final MemberLoansDatasource datasource;
  MemberLoansRepositoryImpl({required this.datasource});

  @override
  Future<MemberLoanPageEntity> getLoans({
    String? status,
    String? loanType,
    String? search,
    String? period,
    String? exactDate,
    int page = 1,
    int limit = 10,
  }) {
    return datasource.getLoans(
      status: status,
      loanType: loanType,
      search: search,
      period: period,
      exactDate: exactDate,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<MemberLoanDetailEntity> getDetail(String loanId) =>
      datasource.getDetail(loanId);

  @override
  Future<String> approve(String loanId, {String? cashRegisterId}) =>
      datasource.approve(loanId, cashRegisterId: cashRegisterId);

  @override
  Future<String> reject(String loanId, String reason) =>
      datasource.reject(loanId, reason);

  @override
  Future<String> cancel(String loanId, String reason) =>
      datasource.cancel(loanId, reason);

  @override
  Future<String> registerPayment(
    String loanId, {
    required String paymentType,
    double? amount,
    String? periodId,
    String? cashRegisterId,
    String? paidAt,
    String? notes,
    String? comprobantePath,
  }) {
    return datasource.registerPayment(
      loanId,
      paymentType: paymentType,
      amount: amount,
      periodId: periodId,
      cashRegisterId: cashRegisterId,
      paidAt: paidAt,
      notes: notes,
      comprobantePath: comprobantePath,
    );
  }

  @override
  Future<MemberLoanReportEntity> getReport({String? period, String? exactDate}) =>
      datasource.getReport(period: period, exactDate: exactDate);

  @override
  Future<List<CashRegisterEntity>> getCashRegisters() =>
      datasource.getCashRegisters();
}
