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
        cajaMayor: json["caja_mayor"],
        cajaChica: json["caja_chica"],
        aDesembolsar: json["a_desembolsar"],
        saldoDisponibleReal: json["saldo_disponible_real"],
      );
}
