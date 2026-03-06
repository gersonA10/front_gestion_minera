import '../entity/money_request_entity.dart';
import '../entity/money_request_response_entity.dart';

abstract class MoneyRequestRepository {
  Future<MoneyRequestResponseEntity> submitMoneyRequest(MoneyRequestEntity request);
}