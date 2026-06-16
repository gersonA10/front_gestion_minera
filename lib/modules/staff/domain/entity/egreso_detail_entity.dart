class EgresoDetailItemEntity {
  final String employeeId;
  final String fullName;
  final String position;
  final int month;
  final int year;
  final double netTotal;

  /// 'PAGADO' | 'PENDIENTE'
  final String paymentStatus;
  final String? paymentDate;

  const EgresoDetailItemEntity({
    required this.employeeId,
    required this.fullName,
    required this.position,
    required this.month,
    required this.year,
    required this.netTotal,
    required this.paymentStatus,
    required this.paymentDate,
  });
}
