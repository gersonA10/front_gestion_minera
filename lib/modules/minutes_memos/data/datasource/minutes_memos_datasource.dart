import 'package:front_gestion_minera/core/networking/http_services.dart';
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
    return MemosCountModel.fromJson(response);
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
    return MemosCountModel.fromJson(response);
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
    await apiClient.postFormData(
      '/api/actas',
      operationName: 'createActa',
      data: model.toJson(),
      files: [
        {
          'name': 'archivo_acta',
          'path': model.attachmentIds.first,
          'namefile': model.attachmentIds.first.split('/').last,
        },
      ],
    );
  }

  Future<void> createdMemorandum(CreateMemorandumEntity memorandum) async {
    final model = CreateMemorandumModel.fromEntity(memorandum);
    await apiClient.postFormData(
      '/api/memorandos',
      operationName: 'createMemorando',
      data: model.toJson(),
      files: [
        {
          'name': 'archivo_memo',
          'path': model.attachmentIds.first,
          'namefile': model.attachmentIds.first.split('/').last,
        },
      ],
    );
  }

  Future<Map<String,String>> uploadFileRecords(FileUploadModel document) async {
    final response = await apiClient.postFormData(
      '/api/uploads',
      operationName: 'uploadFileRecords',
      data: document.toJson(),
      files: [
        {
          'name': 'file',
          'path': document.file,
          'namefile': document.file.split('/').last,
        },
      ],
    );
    return {'attachment': response['attachment_id'],'nombre':response['file_name']};
  }

  Future<String> deleteFileRecord(String attachmentId) async {
    final response = await apiClient.delete(
      'api/upload/$attachmentId',
      operationName: 'deleteFileRecords',
    );
    return response['message'];
  }
}
