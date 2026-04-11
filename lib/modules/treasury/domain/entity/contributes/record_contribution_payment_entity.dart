class RecordContributionPaymentDataEntity {
    final String detailId;
    final String transactionId;

    RecordContributionPaymentDataEntity({
        required this.detailId,
        required this.transactionId,
    });
}

class RecordContributionPaymentRequestEntity {
    final String detailid;
    final String cashRegisterid;
    final String observacion;
    final String evidencia;

    RecordContributionPaymentRequestEntity({
        required this.detailid,
        required this.cashRegisterid,
        required this.observacion,
        required this.evidencia,
    });
}