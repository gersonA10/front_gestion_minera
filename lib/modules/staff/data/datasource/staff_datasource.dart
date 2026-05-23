import 'package:front_gestion_minera/core/networking/http_services.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/entity.dart';

import '../models/models.dart';

class StaffDatasource {
  final ApiClient apiClient;

  StaffDatasource({required this.apiClient});

  Future<PaginatedEmployeesModel> getEmployees({
    String? search,
    String? department,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    if (department != null && department.trim().isNotEmpty) {
      queryParameters['department'] = department.trim();
    }

    if (status != null &&
        status.trim().isNotEmpty &&
        status.toLowerCase() != 'todos') {
      queryParameters['status'] = status.trim();
    }

    final response = await apiClient.get(
      '/api/hr/employees',
      operationName: 'getEmployees',
      queryParameters: queryParameters,
    );

    return PaginatedEmployeesModel.fromJson(response);
  }

  Future<void> registerEmployees(RegisterEmployeesEntity employees) async {
    final model = RegisterEmployeesModel.fromEntity(employees);
    await apiClient.post(
      '/api/hr/employees',
      operationName: 'registerEmployeed',
      data: model.toJson(),
    );
  }

  Future<List<PayrollMonthlyModel>> getPayrollMonthly() async {
    final queryParameters = {
      'month': DateTime.now().month.toString(),
      'year': DateTime.now().year.toString(),
    };
    final response = await apiClient.get(
      '/api/hr/payrolls',
      operationName: 'getPayrollsMonthly',
      queryParameters: queryParameters,
    );
    final List data = response as List;
    return data.map((json) => PayrollMonthlyModel.fromJson(json)).toList();
  }

  Future<void> createPayrollMonthly(CreatePayrollMonthlyEntity payrollenitity) async {
    final modelpayroll = CreatePayrollMonthlyModel.fromEntity(payrollenitity);
    await apiClient.postFormData(
      '/api/hr/payrolls/request-egreso',
      operationName: 'requestPayrollsMonthly',
      data: modelpayroll.toJson(),
      files: [
        {
          'name': 'planilla_url',
          'path': modelpayroll.planillaUrl,
          'filename': modelpayroll.planillaUrl.split('/').last,
        },
      ],
    );
  }
}
