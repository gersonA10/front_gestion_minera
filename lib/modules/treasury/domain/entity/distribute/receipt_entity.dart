class ReceiptResponseEneity {
    final String memberName;
    final String identification;
    final String period;
    final int paidAmount;
    final DateTime paymentDate;
    final String affectedCashbox;
    final String reference;
    final String transactionId;
    final String evidenceUrl;

    ReceiptResponseEneity({
        required this.memberName,
        required this.identification,
        required this.period,
        required this.paidAmount,
        required this.paymentDate,
        required this.affectedCashbox,
        required this.reference,
        required this.transactionId,
        required this.evidenceUrl,
    });
}
