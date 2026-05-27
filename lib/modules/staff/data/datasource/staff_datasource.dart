import 'package:front_gestion_minera/core/networking/http_services.dart';
import '../models/models.dart';


class StaffDatasource {
  final ApiClient apiClient;

  StaffDatasource({
    required this.apiClient,
  });

  Future<PaginatedEmployeesModel> getEmployees({
    String? search,
    String? department,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'page': page,
      'limit': limit,
    };

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

  Future<EmployeeModel> getEmployeeById(String id) async {
    final response = await apiClient.get(
      '/api/hr/employees/$id',
      operationName: 'getEmployeeById',
    );
    return EmployeeModel.fromJson(response['data']);
  }
}
