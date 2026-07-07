import 'package:front_gestion_minera/core/networking/http_services.dart';
import '../../domain/entity/member_inbox_entity.dart';
import '../models/member_inbox_model.dart';

class MemberInboxDatasource {
  final ApiClient apiClient;
  MemberInboxDatasource({required this.apiClient});

  Future<List<MemberInboxItemEntity>> getInbox() async {
    final response = await apiClient.get(
      '/api/socios/bandeja',
      operationName: 'brings up the member inbox',
    );

    return MemberInboxResponseModel.fromJson(response).data;
  }
}
