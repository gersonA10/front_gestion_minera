import 'package:front_gestion_minera/modules/minutes_memos/data/models/models.dart';
import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/create_acta_entity.dart';
import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/create_memorandum_entity.dart';
import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/entity.dart';

import '../../domain/entity/acta_entity.dart';
import '../../domain/entity/memos_count_entity.dart';
import '../../domain/entity/memorandum_entity.dart';
import '../../domain/repositories/minutes_memos_repository.dart';
import '../datasource/minutes_memos_datasource.dart';

class MinutesMemosRepositoryImpl implements MinutesMemosRepository {
  final MinutesMemosDatasource datasource;

  MinutesMemosRepositoryImpl({required this.datasource});

  @override
  Future<MemosCountEntity> getActasCount({
    String? filter,
    String? from,
    String? to,
  }) {
    return datasource.getActasCount(filter: filter, from: from, to: to);
  }

  @override
  Future<MemosCountEntity> getMemosCount({
    String? filter,
    String? from,
    String? to,
  }) {
    return datasource.getMemosCount(filter: filter, from: from, to: to);
  }

  @override
  Future<MemorandosListEntity> getMemorandos({
    String? filter,
    String? from,
    String? to,
    int page = 1,
    int limit = 10,
  }) {
    return datasource.getMemorandos(
      filter: filter,
      from: from,
      to: to,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<ActasListEntity> getActas({
    String? filter,
    String? from,
    String? to,
    int page = 1,
    int limit = 10,
  }) {
    return datasource.getActas(
      filter: filter,
      from: from,
      to: to,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<void> createActa(CreateActaEntity acta) => 
    datasource.createActa(acta);

  @override
  Future<void> createMemorandum(CreateMemorandumEntity memorandum) =>
      datasource.createdMemorandum(memorandum);

  @override
  Future<String> uploadFileRecords(FileUploadEntity files){
    final model = FileUploadModel.fromEntity(files);
    return datasource.uploadFileRecords(model);
  }

  @override
  Future<String> deleteFileRecord(String attachmentId){
    return datasource.deleteFileRecord(attachmentId);
  }
}
