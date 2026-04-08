import '../../domain/entity/entity.dart';

class BondBalanceResponseModel extends BondBalanceResponseEntity {
  BondBalanceResponseModel({
    required super.cajaMayor,
    required super.cajaChica,
    required super.aDesembolsar,
    required super.saldoDisponibleReal,
  });

  factory BondBalanceResponseModel.fromJson(Map<String, dynamic> json) =>
      BondBalanceResponseModel(
        cajaMayor: (json["caja_mayor"] as num).toDouble(),
        cajaChica: (json["caja_chica"] as num).toDouble(),
        aDesembolsar: (json["a_desembolsar"] as num).toDouble(),
        saldoDisponibleReal: (json["saldo_disponible_real"] as num).toDouble(),
      );
}
