import '../../domain/entity/money_request_entity.dart';
import '../../domain/entity/money_request_response_entity.dart';
import '../../domain/repositories/money_request_repository.dart';
import '../datasource/money_request_datasource.dart';
import '../models/money_request_model.dart';

class MoneyRequestRepositoryImpl implements MoneyRequestRepository {
  final MoneyRequestDatasource datasource;

  MoneyRequestRepositoryImpl({required this.datasource});

  @override
  Future<MoneyRequestResponseEntity> submitMoneyRequest(MoneyRequestEntity requestEntity) async {
    final requestModel = MoneyRequestModel.fromEntity(requestEntity);
    final response = await datasource.submitMoneyRequest(requestModel);
    return response.toEntity();
  }
}

