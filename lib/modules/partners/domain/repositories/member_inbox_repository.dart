import '../entity/member_inbox_entity.dart';

abstract class MemberInboxRepository {
  Future<List<MemberInboxItemEntity>> getInbox();
}
