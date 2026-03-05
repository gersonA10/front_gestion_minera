import '../../../../core/networking/http_services.dart';
import '../../domain/entity/entity.dart';
import '../models/model.dart';

class PartnersDatasource {
  final ApiClient apiClient;
  PartnersDatasource({required this.apiClient});
  Future<List<LoanHistoryDataEntity>> getcontributeHistory() async {
    final response = await apiClient.get(
      '/api/contributions/history',
      operationName: 'brings up the weeks transaction history',
    );

    return List<LoanHistoryDataModel>.from(response);
  }

  Future<List<LoanHistoryDataEntity>> getcontributeHistoryWeek() async {
    final response = await apiClient.get(
      '/api/contributions/history',
      queryParameters: {'period': 'week'},
      operationName: 'brings up the weeks transaction history',
    );

    return List<LoanHistoryDataModel>.from(response);
  }

  Future<List<LoanHistoryDataEntity>> getcontributeHistoryMonth(
    String date,
  ) async {
    final response = await apiClient.get(
      '/api/contributions/history',
      queryParameters: {'period': 'month', '&extract_date': date},
      operationName: 'brings up the transaction history for the month',
    );

    return List<LoanHistoryDataModel>.from(response);
  }

  Future<List<LoanHistoryDataEntity>> getcontributeHistoryYear(
    String date,
  ) async {
    final response = await apiClient.get(
      '/api/contributions/history',
      queryParameters: {'period': 'year', '&extract_date': date},
      operationName: 'brings up the transaction history for the year',
    );

    return List<LoanHistoryDataModel>.from(response);
  }
}
