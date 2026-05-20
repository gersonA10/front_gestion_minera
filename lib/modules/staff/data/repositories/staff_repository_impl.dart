import '../../domain/entity/entity.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasource/staff_datasource.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffDatasource datasource;

  StaffRepositoryImpl({
    required this.datasource,
  });
  
  @override
  Future<void> registerEmployees(RegisterEmployeesEntity employees) =>
    datasource.registerEmployees(employees);
    
}