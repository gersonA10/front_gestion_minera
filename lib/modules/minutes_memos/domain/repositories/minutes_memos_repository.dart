import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/create_acta_entity.dart';
import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/create_memorandum_entity.dart';

import '../entity/acta_entity.dart';
import '../entity/memos_count_entity.dart';
import '../entity/memorandum_entity.dart';

abstract class MinutesMemosRepository {
  Future<MemosCountEntity> getActasCount({
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
}
