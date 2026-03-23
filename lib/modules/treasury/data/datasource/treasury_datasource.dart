
import 'package:front_gestion_minera/modules/treasury/data/models/financial_report_model.dart';
import '../../../../core/networking/http_services.dart';
import '../../domain/entity/entity.dart';
import '../models/model.dart';

class TreasuryDatasource {
  final ApiClient apiClient;

  TreasuryDatasource({required this.apiClient});

  Future<TreasuryMetricsModel> getMetrics() async {
    final response = await apiClient.get(
      '/api/treasury/dashboard/home',
      operationName: 'getTreasuryMetrics',
    );
    return TreasuryMetricsModel.fromJson(response['data']);
  }

  Future<BondBalanceResponseModel> getBondBalence() async {
    final response = await apiClient.get(
      '/api/treasury/finance/balances',
      operationName: 'getBondBalence',
    );
    return BondBalanceResponseModel.fromJson(response['data']);
  }

  Future<PendingApplicationsResponseEntity> getPendingApplications() async {
    final response = await apiClient.get(
      '/api/treasury/requests/recent',
      operationName: 'getPendingApplications',
    );
    return PendingApplicationsResponseModel.fromJson(response);
  }

  Future<DetailsofanapplicationResponseEntity> getDetailsofanapplication(
    String id,
  ) async {
    final response = await apiClient.get(
      '/api/treasury/requests/$id',
      operationName: 'getDetailsofanapplication',
    );
    return DetailsofanapplicationResponseModel.fromJson(response);
  }

  Future<FinancialReportModel> getFinancialReport({
    String period = 'month',
    String? exactDate,
  }) async {
    final queryParams = <String, dynamic>{'period': period};
    if (exactDate != null && exactDate.isNotEmpty) {
      queryParams['exact_date'] = exactDate;
    }

    final response = await apiClient.get(
      '/api/treasury/reports/financial',
      queryParameters: queryParams,
      operationName: 'getFinancialReport',
    );

    return FinancialReportModel.fromJson(response['data']);
  }

  Future<List<CashRegisterModel>> getCashRegisters() async {
    final response = await apiClient.get(
      '/api/treasury/cash-registers',
      operationName: 'getCashRegisters',
    );
    
    final List data = response['data'];
    return data.map((e) => CashRegisterModel.fromJson(e)).toList();
  }

  Future<IncomeResponseModel> registerUrgentIncome(
    IncomeRequestModel incomeRequestModel,
  ) async {
    final response = await apiClient.postFormData(
      '/api/treasury/urgent/income',
      data: incomeRequestModel.toFormDataMap(),
      operationName: 'registerUrgentIncome',
      files: [
        {
          'name': 'evidencia',
          'path': incomeRequestModel.evidenceUrlPath,
          'filename': incomeRequestModel.evidenceUrlPath.split('/').last
        }
      ]
    );

    return IncomeResponseModel.fromJson(response['data']);
  }
}
