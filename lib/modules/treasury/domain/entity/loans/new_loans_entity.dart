
class NewLoansResponseEntity {
    final SummaryEntity summary;
    final List<CronogramaEntity> cronograma;

    NewLoansResponseEntity({
        required this.summary,
        required this.cronograma,
    });
}

class CronogramaEntity {
    final int installmentNumber;
    final DateTime dueDate;
    final String status;
    final double principal;
    final double interest;
    final double totalInstallment;

    CronogramaEntity({
        required this.installmentNumber,
        required this.dueDate,
        required this.status,
        required this.principal,
        required this.interest,
        required this.totalInstallment,
    });
}

class SummaryEntity {
    final double amount;
    final double totalInterest;
    final double totalPayable;
    final int termMonths;
    final double monthlyInstallment;

    SummaryEntity({
        required this.amount,
        required this.totalInterest,
        required this.totalPayable,
        required this.termMonths,
        required this.monthlyInstallment,
    });
}
