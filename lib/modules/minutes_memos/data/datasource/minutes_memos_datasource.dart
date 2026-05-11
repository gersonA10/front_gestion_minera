import 'package:front_gestion_minera/core/networking/http_services.dart';
import 'package:front_gestion_minera/modules/minutes_memos/data/models/create_acta_model.dart';
import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/entity.dart';
import '../models/models.dart';

class MinutesMemosDatasource {
  final ApiClient apiClient;
  MinutesMemosDatasource({required this.apiClient});

  Future<MemosCountModel> getMemosCount({
    String? filter,
    String? from,
    String? to,
  }) async {
    final params = <String, dynamic>{};
    if (filter != null) params['filter'] = filter;
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;

    final response = await apiClient.get(
      '/api/memorandos/count',
      operationName: 'getMemosCount',
      queryParameters: params.isEmpty ? null : params,
    );
    return MemosCountModel.fromJson(response['data']);
  }

  Future<MemorandosListModel> getMemorandos({
    String? filter,
    String? from,
    String? to,
    int page = 1,
    int limit = 10,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (filter != null) params['filter'] = filter;
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;

    final response = await apiClient.get(
      '/api/memorandos',
      operationName: 'getMemorandos',
      queryParameters: params,
    );
    return MemorandosListModel.fromJson(response);
  }

  Future<MemosCountModel> getActasCount({
    String? filter,
    String? from,
    String? to,
  }) async {
    final params = <String, dynamic>{};
    if (filter != null) params['filter'] = filter;
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;

    final response = await apiClient.get(
      '/api/actas/count',
      operationName: 'getActasCount',
      queryParameters: params.isEmpty ? null : params,
    );
    return MemosCountModel.fromJson(response['data']);
  }

  Future<ActasListModel> getActas({
    String? filter,
    String? from,
    String? to,
    int page = 1,
    int limit = 10,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (filter != null) params['filter'] = filter;
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;

    final response = await apiClient.get(
      '/api/actas',
      operationName: 'getActas',
      queryParameters: params,
    );
    return ActasListModel.fromJson(response);
  }

  Future<void> createActa(CreateActaEntity acta) async {
    final model = CreateActaModel.fromEntity(acta);
    final response = await apiClient.postFormData(
      '/api/actas',
      operationName: 'createActa',
      data: model.toJson()
    );
  }
}
