import '../../domain/entity/egreso_detail_entity.dart';

class EgresoDetailItemModel extends EgresoDetailItemEntity {
  const EgresoDetailItemModel({
    required super.employeeId,
    required super.fullName,
    required super.position,
    required super.month,
    required super.year,
    required super.netTotal,
    required super.paymentStatus,
    required super.paymentDate,
  });

  factory EgresoDetailItemModel.fromJson(Map<String, dynamic> json) =>
      EgresoDetailItemModel(
        employeeId: json['employee_id']?.toString() ?? '',
        fullName: json['full_name'] ?? '',
        position: json['position'] ?? '',
        month: json['month'] ?? 0,
        year: json['year'] ?? 0,
        netTotal: (json['net_total'] ?? 0).toDouble(),
        paymentStatus: json['payment_status'] ?? 'PENDIENTE',
        paymentDate: json['payment_date'],
      );
}
