import 'package:front_gestion_minera/modules/partners/domain/entity/request_history_entity.dart';

import '../entity/money_request_entity.dart';
import '../entity/money_request_response_entity.dart';

abstract class MoneyRequestRepository {
  Future<MoneyRequestResponseEntity> submitMoneyRequest(MoneyRequestEntity request);
  // Future<List<RequestHistoryEntity>> getHistory({String? status, String? search});
  Future<PaginatedHistoryEntity> getHistory({String? status, String? search, int page = 1, int limit = 10});
}