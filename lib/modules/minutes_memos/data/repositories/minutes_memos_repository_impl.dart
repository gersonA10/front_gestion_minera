import '../../domain/entity/entity.dart';
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
  Future<void> createActa(CreateActaEntity acta) => datasource.createActa(acta);

  @override
  Future<void> createMemorandum(CreateMemorandumEntity memorandum) =>
      datasource.createdMemorandum(memorandum);
      
  @override
  Future<MemorandumDetailEntity> getMemorandumDetail(String memoId) {
    return datasource.getMemorandumDetail(memoId);
  }
}
