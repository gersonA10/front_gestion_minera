class DetailMaintenanceResponseEntity {
    String maintenanceId;
    String failureType;
    String description;
    int estimatedAmount;
    String evidenceUrl;
    DateTime requestedAt;
    MachineData machine;
    RequestData request;

    DetailMaintenanceResponseEntity({
        required this.maintenanceId,
        required this.failureType,
        required this.description,
        required this.estimatedAmount,
        required this.evidenceUrl,
        required this.requestedAt,
        required this.machine,
        required this.request,
    });

}

class MachineData {
    String machineId;
    String name;
    String uniqueCode;
    String type;
    String status;
    String photoUrl;

    MachineData({
        required this.machineId,
        required this.name,
        required this.uniqueCode,
        required this.type,
        required this.status,
        required this.photoUrl,
    });

}

class RequestData {
    String globalStatus;
    String securityStatus;
    String administrationStatus;
    dynamic rejectReason;
    int requestedAmount;
    dynamic paidAt;

    RequestData({
        required this.globalStatus,
        required this.securityStatus,
        required this.administrationStatus,
        required this.rejectReason,
        required this.requestedAmount,
        required this.paidAt,
    });

}
