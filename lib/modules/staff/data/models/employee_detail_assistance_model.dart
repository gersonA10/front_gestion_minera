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
    required super.geoLocation,
    required super.audit,
  });

  factory EmployeeDetailAssistanceModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDetailAssistanceModel(
      attendanceId: json['attendance_id'],
      date: json['date'],
      assignedShift: json['assigned_shift'],
      attendanceStatus: json['attendance_status'],

      employee: Employee(
        employeeId: json['employee']['employee_id'],
        fullName: json['employee']['full_name'],
        position: json['employee']['position'],
        photoUrl: json['employee']['photo_url'],
      ),

      chronology: Chronology(
        checkIn: ChronologyCheckIn(
          time: json['chronology']['check_in']['time'],
          location: json['chronology']['check_in']['location'],
        ),
        breakMinutes: json['chronology']['break_minutes'],
        checkOut: ChronologyCheckIn(
          time: json['chronology']['check_out']['time'],
          location: json['chronology']['check_out']['location'],
        ),
        netHoursWorked: (json['chronology']['net_hours_worked'] as num)
            .toDouble(),
      ),

      validation: Validation(
        autoValidated: json['validation']['auto_validated'],
        supervisorSignatureUrl: json['validation']['supervisor_signature_url'],
      ),

      geoLocation: GeoLocation(
        checkIn: GeoLocationCheckIn(
          latitude: (json['geo_location']['check_in']['latitude'] as num)
              .toDouble(),
          longitude: (json['geo_location']['check_in']['longitude'] as num)
              .toDouble(),
        ),
        checkOut: GeoLocationCheckIn(
          latitude: (json['geo_location']['check_out']['latitude'] as num)
              .toDouble(),
          longitude: (json['geo_location']['check_out']['longitude'] as num)
              .toDouble(),
        ),
      ),

      audit: Audit(
        registeredBy: RegisteredBy(
          userId: json['audit']['registered_by']['user_id'],
          fullName: json['audit']['registered_by']['full_name'],
        ),
        correctionsHistory: List<dynamic>.from(
          json['audit']['corrections_history'],
        ),
      ),
    );
  }
}
