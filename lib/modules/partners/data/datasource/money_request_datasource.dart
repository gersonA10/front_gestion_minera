import 'package:front_gestion_minera/core/networking/http_services.dart';
import '../models/money_request_model.dart';
import '../models/money_request_response_model.dart';

class MoneyRequestDatasource {
  final ApiClient apiClient;

  MoneyRequestDatasource({required this.apiClient});

  Future<MoneyRequestResponseModel> submitMoneyRequest(MoneyRequestModel requestModel) async {
    final response = await apiClient.postFormData(
      '/api/requests/register',
      operationName: 'submitMoneyRequest',
      data: requestModel.toFormDataMap(), // Usamos el mapeo de los textos
      files: [
        {
          'name': 'evidencia_url', 
          'path': requestModel.evidenceUrlPath,
          'filename': requestModel.evidenceUrlPath.split('/').last,
        }
      ],
    );

    return MoneyRequestResponseModel.fromJson(response);
  }
}