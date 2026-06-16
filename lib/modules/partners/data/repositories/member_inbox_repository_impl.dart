import '../../domain/entity/member_inbox_entity.dart';
import '../../domain/repositories/member_inbox_repository.dart';
import '../datasource/member_inbox_datasource.dart';

class MemberInboxRepositoryImpl extends MemberInboxRepository {
  final MemberInboxDatasource datasource;
  MemberInboxRepositoryImpl({required this.datasource});

  @override
  Future<List<MemberInboxItemEntity>> getInbox() async {
    return await datasource.getInbox();
  }
}
