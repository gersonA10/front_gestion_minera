import '../../domain/entity/cash_register_entity.dart';
import '../json_parse.dart';

class CashRegisterModel extends CashRegisterEntity {
  CashRegisterModel({
    required super.id,
    required super.nombre,
    super.saldoDisponible,
  });

  factory CashRegisterModel.fromJson(Map<String, dynamic> json) =>
      CashRegisterModel(
        id: pStr(json['id']),
        nombre: pStr(json['nombre']),
        saldoDisponible: pNum(json['saldo_disponible']),
      );
}
