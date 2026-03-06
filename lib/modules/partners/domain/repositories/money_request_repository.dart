import '../entity/money_request_entity.dart';

abstract class MoneyRequestRepository {
  Future<bool> submitMoneyRequest(MoneyRequestEntity request);
}