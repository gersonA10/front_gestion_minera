import 'package:front_gestion_minera/core/networking/http_services.dart';

import '../../domain/entity/cash_register_entity.dart';
import '../../domain/entity/member_loan_detail_entity.dart';
import '../../domain/entity/member_loan_list_entity.dart';
import '../../domain/entity/member_loan_report_entity.dart';
import '../models/cash_register_model.dart';
import '../models/member_loan_detail_model.dart';
import '../models/member_loan_list_model.dart';
import '../models/member_loan_report_model.dart';

class MemberLoansDatasource {
  final ApiClient apiClient;
  MemberLoansDatasource({required this.apiClient});

  /// §5.1 GET /api/treasury/members/loans
  Future<MemberLoanPageEntity> getLoans({
    String? status,
    String? loanType,
    String? search,
    String? period,
    String? exactDate,
    int page = 1,
    int limit = 10,
  }) async {
    final qp = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null && status.trim().isNotEmpty) qp['status'] = status;
    if (loanType != null && loanType.trim().isNotEmpty) {
      qp['loan_type'] = loanType;
    }
    if (search != null && search.trim().isNotEmpty) qp['search'] = search.trim();
    if (period != null) qp['period'] = period;
    if (exactDate != null) qp['exact_date'] = exactDate;

    final response = await apiClient.get(
      '/api/treasury/members/loans',
      operationName: 'getMemberLoans',
      queryParameters: qp,
    );
    return MemberLoanListItemModel.pageFromResponse(
      response as Map<String, dynamic>,
    );
  }

  /// §5.2 GET /api/treasury/members/loans/:id
  Future<MemberLoanDetailEntity> getDetail(String loanId) async {
    final response = await apiClient.get(
      '/api/treasury/members/loans/$loanId',
      operationName: 'getMemberLoanDetail',
    );
    return MemberLoanDetailModel.fromJson(response['data'] ?? {});
  }

  /// §5.3 POST /api/treasury/members/loans/:id/approve
  Future<String> approve(String loanId, {String? cashRegisterId}) async {
    final data = <String, dynamic>{};
    if (cashRegisterId != null) data['cash_register_id'] = cashRegisterId;
    final response = await apiClient.post(
      '/api/treasury/members/loans/$loanId/approve',
      operationName: 'approveMemberLoan',
      data: data,
    );
    return (response['message'] ?? 'Préstamo aprobado correctamente.')
        .toString();
  }

  /// §5.4 POST /api/treasury/members/loans/:id/reject
  Future<String> reject(String loanId, String reason) async {
    final response = await apiClient.post(
      '/api/treasury/members/loans/$loanId/reject',
      operationName: 'rejectMemberLoan',
      data: {'reason': reason},
    );
    return (response['message'] ?? 'Préstamo rechazado correctamente.')
        .toString();
  }

  /// §5.5 POST /api/treasury/members/loans/:id/cancel
  Future<String> cancel(String loanId, String reason) async {
    final response = await apiClient.post(
      '/api/treasury/members/loans/$loanId/cancel',
      operationName: 'cancelMemberLoan',
      data: {'reason': reason},
    );
    return (response['message'] ?? 'Préstamo cancelado correctamente.')
        .toString();
  }

  /// §5.6 POST /api/treasury/members/loans/:id/payments (multipart)
  Future<String> registerPayment(
    String loanId, {
    required String paymentType, // INTEREST | PRINCIPAL
    double? amount,
    String? periodId,
    String? cashRegisterId,
    String? paidAt,
    String? notes,
    String? comprobantePath,
  }) async {
    final data = <String, dynamic>{'payment_type': paymentType};
    if (amount != null) data['amount'] = amount;
    if (periodId != null) data['period_id'] = periodId;
    if (cashRegisterId != null) data['cash_register_id'] = cashRegisterId;
    if (paidAt != null) data['paid_at'] = paidAt;
    if (notes != null && notes.trim().isNotEmpty) data['notes'] = notes.trim();

    final files = <Map<String, dynamic>>[];
    if (comprobantePath != null && comprobantePath.isNotEmpty) {
      files.add({
        'name': 'comprobante',
        'path': comprobantePath,
        'filename': comprobantePath.split('/').last,
      });
    }

    final response = await apiClient.postFormData(
      '/api/treasury/members/loans/$loanId/payments',
      operationName: 'registerMemberLoanPayment',
      data: data,
      files: files.isEmpty ? null : files,
    );
    return (response['message'] ?? 'Pago registrado correctamente.').toString();
  }

  /// §5.7 GET /api/treasury/members/loans/report
  Future<MemberLoanReportEntity> getReport({
    String? period,
    String? exactDate,
  }) async {
    final qp = <String, dynamic>{};
    if (period != null) qp['period'] = period;
    if (exactDate != null) qp['exact_date'] = exactDate;

    final response = await apiClient.get(
      '/api/treasury/members/loans/report',
      operationName: 'getMemberLoansReport',
      queryParameters: qp.isEmpty ? null : qp,
    );
    return MemberLoanReportModel.fromJson(response['data'] ?? {});
  }

  /// GET /api/treasury/cash-registers (selector de cajas)
  Future<List<CashRegisterEntity>> getCashRegisters() async {
    final response = await apiClient.get(
      '/api/treasury/cash-registers',
      operationName: 'getCashRegistersForMemberLoans',
    );
    final List data = response['data'] ?? [];
    return data
        .map((e) => CashRegisterModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
