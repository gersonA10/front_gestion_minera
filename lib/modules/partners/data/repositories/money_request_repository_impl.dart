import 'package:front_gestion_minera/modules/partners/data/models/request_history_model.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/request_history_entity.dart';

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

  @override
  Future<PaginatedHistoryEntity> getHistory({String? status, String? search, int page = 1, int limit = 10}) async {
    final result = await datasource.getHistory(status: status, search: search, page: page, limit: limit);
    
    final models = result['items'] as List<RequestHistoryModel>;
    return PaginatedHistoryEntity(
      items: models.map((model) => model.toEntity()).toList(),
      hasMoreData: result['has_more_data'] as bool,
    );
  }
}

