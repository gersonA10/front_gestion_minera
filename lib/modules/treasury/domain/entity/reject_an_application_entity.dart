class RejectAnApplicationResponseEntity {
    final bool success;
    final String message;
    final RejectAnApplicationDataEntity data;

    RejectAnApplicationResponseEntity({
        required this.success,
        required this.message,
        required this.data,
    });
}

class RejectAnApplicationDataEntity {
    final String description;
    RejectAnApplicationDataEntity({
        required this.description,
    });
}
