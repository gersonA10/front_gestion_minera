

import '../entity/entity.dart';


abstract class MinutesMemosRepository {
  Future<ActasCountEntity> getActasCount({
    String? filter,
    String? from,
    String? to,
  });

  Future<MemosCountEntity> getMemosCount({
    String? filter,
    String? from,
    String? to,
  });

  Future<MemorandosListEntity> getMemorandos({
    String? filter,
    String? from,
    String? to,
    int page,
    int limit,
  });

  Future<ActasListEntity> getActas({
    String? filter,
    String? from,
    String? to,
    int page,
    int limit,
  });
  Future<void> createActa(CreateActaEntity acta);
  Future<void> createMemorandum(CreateMemorandumEntity memorandum);
  Future<MemorandumDetailEntity> getMemorandumDetail(
  String memoId,
);
}
