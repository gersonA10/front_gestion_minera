import 'package:front_gestion_minera/modules/staff/domain/entity/entity.dart';

class CreatePayrollMonthlyModel extends CreatePayrollMonthlyEntity {
  CreatePayrollMonthlyModel({
    required super.month,
    required super.year,
    required super.justification,
    required super.planillaUrl,
  });

  factory CreatePayrollMonthlyModel.fromEntity(
    CreatePayrollMonthlyEntity entity,
  ) {
    return CreatePayrollMonthlyModel(
      month: entity.month,
      year: entity.year,
      justification: entity.justification,
      planillaUrl: entity.planillaUrl,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'month': month, 
      'year': year, 
      'justification': justification
      };
  }
}
