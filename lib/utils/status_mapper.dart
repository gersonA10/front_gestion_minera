extension RequestStatusMapper on String {
  String get toSpanish {
    switch (this) {
      case 'IN_REVIEW':
        return 'EN REVISIÓN';
      case 'APPROVED':
        return 'APROBADO';
      case 'REJECTED':
        return 'RECHAZADO';
      case 'PAID':
        return 'PAGADO';
      default:
        return this;
    }
  }
}