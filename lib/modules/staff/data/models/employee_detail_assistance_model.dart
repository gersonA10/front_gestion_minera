import 'package:front_gestion_minera/modules/staff/domain/entity/entity.dart';

class EmployeeDetailAssistanceModel extends EmployeeDetailAssistanceEntity {
  EmployeeDetailAssistanceModel({
    required super.attendanceId,
    required super.date,
    required super.assignedShift,
    required super.attendanceStatus,
    required super.employee,
    required super.chronology,
    required super.validation,
    required super.audit,
  });

  factory EmployeeDetailAssistanceModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDetailAssistanceModel(
      attendanceId: json['attendance_id'] ?? '',
      date: json['date'] ?? '',
      assignedShift: json['assigned_shift'] ?? '',
      attendanceStatus: json['attendance_status'] ?? '',
      employee: EmployeeDetailModel.fromJson(json['employee']),
      chronology: ChronologyModel.fromJson(json['chronology']),
      validation: ValidationModel.fromJson(json['validation']),
      audit: AuditModel.fromJson(json['audit']),
    );
  }
}

class AuditModel extends Audit {
  AuditModel({required super.registeredBy, required super.correctionsHistory});

  factory AuditModel.fromJson(Map<String, dynamic> json) {
    return AuditModel(
      registeredBy: RegisteredBymodel.fromJson(json['registered_by'] ?? {}),
      correctionsHistory: List<dynamic>.from(json['corrections_history'] ?? []),
    );
  }
}

class RegisteredBymodel extends RegisteredBy {
  RegisteredBymodel({required super.userId, required super.fullName});
  factory RegisteredBymodel.fromJson(Map<String, dynamic> json) {
    return RegisteredBymodel(
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
    );
  }
}

class ChronologyModel extends Chronology {
  ChronologyModel({
    required super.checkIn,
    required super.breakMinutes,
    required super.checkOut,
    required super.netHoursWorked,
  });
  factory ChronologyModel.fromJson(Map<String, dynamic> json) {
    return ChronologyModel(
      checkIn: ChronologyCheckInModel.fromJson(json['check_in']),
      breakMinutes: json['break_minutes'] ?? 0,
      checkOut: ChronologyCheckInModel.fromJson(json['check_out']),
      netHoursWorked: (json['net_hours_worked'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ChronologyCheckInModel extends ChronologyCheckIn {
  ChronologyCheckInModel({required super.time, required super.location});
  factory ChronologyCheckInModel.fromJson(Map<String, dynamic> json) {
    return ChronologyCheckInModel(
      time: json['time'],
      location: json['location'],
    );
  }
}

class EmployeeDetailModel extends Employee {
  EmployeeDetailModel({
    required super.employeeId,
    required super.nationalId,
    required super.fullName,
    required super.position,
    required super.photoUrl,
  });
  factory EmployeeDetailModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDetailModel(
      employeeId: json['employee_id'] ?? '',
      nationalId: json['national_id'] ?? '',
      fullName: json['full_name'] ?? '',
      position: json['position'] ?? '',
      photoUrl: json['photo_url'],
    );
  }
}

class GeoLocationModel extends GeoLocation {
  GeoLocationModel({required super.checkIn, required super.checkOut});
  factory GeoLocationModel.fromJson(Map<String, dynamic> json) {
    return GeoLocationModel(
      checkIn: GeoLocationCheckInModel.fromJson(json['check_in']),
      checkOut: GeoLocationCheckInModel.fromJson(json['check_out']),
    );
  }
}

class GeoLocationCheckInModel extends GeoLocationCheckIn {
  GeoLocationCheckInModel({required super.latitude, required super.longitude});
  factory GeoLocationCheckInModel.fromJson(Map<String, dynamic> json) {
    return GeoLocationCheckInModel(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

class ValidationModel extends Validation {
  ValidationModel({
    required super.autoValidated,
    required super.supervisorSignatureUrl,
    required super.geolocation,
  });
  factory ValidationModel.fromJson(Map<String, dynamic> json) {
    return ValidationModel(
      autoValidated: json['auto_validated'] ?? false,
      supervisorSignatureUrl: json['supervisor_signature_url'],
      geolocation: GeoLocationModel.fromJson(json['geo_location'])
    );
  }
}
