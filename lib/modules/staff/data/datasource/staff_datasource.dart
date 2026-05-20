import 'package:front_gestion_minera/core/networking/http_services.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/entity.dart';

import '../models/models.dart';

class StaffDatasource {
  final ApiClient apiClient;

  StaffDatasource({required this.apiClient});

  Future<void> registerEmployees(RegisterEmployeesEntity employees) async {
    final model = RegisterEmployeesModel.fromEntity(employees);
    await apiClient.postFormData(
      '/api/hr/employees',
      operationName: 'registerEmployeed',
      data: model.toJson(),
      files: []
    );
  }
}
