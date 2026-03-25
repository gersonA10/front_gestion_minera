import 'package:front_gestion_minera/modules/treasury/domain/entity/cash_register_entity.dart';

class CashRegisterModel extends CashRegisterEntity {
  CashRegisterModel({
    required super.id,
    required super.nombre,
    required super.saldoDisponible,
  });

  factory CashRegisterModel.fromJson(Map<String, dynamic> json) {
    return CashRegisterModel(
      id: json['id'],
      nombre: json['nombre'],
      saldoDisponible: (json['saldo_disponible'] as num).toDouble(),
    );
  }
}
