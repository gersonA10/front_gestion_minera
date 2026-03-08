import 'package:front_gestion_minera/core/networking/http_services.dart';
import '../../domain/entity/entity.dart';
import '../models/loan_history_model.dart';

class LoanHistoryDatasource {
  final ApiClient apiClient;
  LoanHistoryDatasource({required this.apiClient});
  Future<List<LoanHistoryDataEntity>> getLoanHistory() async {
    final response = await apiClient.get(
      '/api/loans/history',
      operationName: 'brings up the loan history',
    );

    return LoanHistoryResponseModel.fromJson(response).data;
  }

  Future<List<LoanHistoryDataEntity>> getLoanHistoryStatus(
    String status,
  ) async {
    final response = await apiClient.get(
      '/api/loans/history?',
      queryParameters: {'status': status},
      operationName: 'brings up the loan history',
    );

    return LoanHistoryResponseModel.fromJson(response).data;
  }
}
