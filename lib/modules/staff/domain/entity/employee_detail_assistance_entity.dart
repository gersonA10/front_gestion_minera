class EmployeeDetailAssistanceEntity {
  final String attendanceId;
  final String date;
  final String assignedShift;
  final String attendanceStatus;
  final Employee employee;
  final Chronology chronology;
  final Validation validation;
  final Audit audit;

  EmployeeDetailAssistanceEntity({
    required this.attendanceId,
    required this.date,
    required this.assignedShift,
    required this.attendanceStatus,
    required this.employee,
    required this.chronology,
    required this.validation,
    required this.audit,
  });
}

class Audit {
  final RegisteredBy registeredBy;
  final List<dynamic> correctionsHistory;

  Audit({required this.registeredBy, required this.correctionsHistory});
}

class RegisteredBy {
  final String userId;
  final String fullName;

  RegisteredBy({required this.userId, required this.fullName});
}

class Chronology {
  final ChronologyCheckIn checkIn;
  final int breakMinutes;
  final ChronologyCheckIn checkOut;
  final double netHoursWorked;

  Chronology({
    required this.checkIn,
    required this.breakMinutes,
    required this.checkOut,
    required this.netHoursWorked,
  });
}

class ChronologyCheckIn {
  final String? time;
  final String? location;

  ChronologyCheckIn({required this.time, required this.location});
}

class Employee {
  final String employeeId;
  final String nationalId;
  final String fullName;
  final String position;
  final String? photoUrl;

  Employee({
    required this.employeeId,
    required this.nationalId,
    required this.fullName,
    required this.position,
    required this.photoUrl,
  });
}

class GeoLocation {
  final GeoLocationCheckIn checkIn;
  final GeoLocationCheckIn checkOut;

  GeoLocation({required this.checkIn, required this.checkOut});
}

class GeoLocationCheckIn {
  final double? latitude;
  final double? longitude;

  GeoLocationCheckIn({required this.latitude, required this.longitude});
}

class Validation {
  final bool autoValidated;
  final String supervisorSignatureUrl;
  final GeoLocation geolocation;

  Validation({
    required this.autoValidated,
    required this.supervisorSignatureUrl,
    required this.geolocation,
  });
}
