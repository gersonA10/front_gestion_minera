import '../entity/entity.dart';

abstract class StaffRepository {
  Future<void> registerEmployees(RegisterEmployeesEntity employees);
}