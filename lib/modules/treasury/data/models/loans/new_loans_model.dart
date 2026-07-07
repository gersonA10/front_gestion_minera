import '../../../domain/entity/entity.dart';

class NewLoansResponseModel extends NewLoansResponseEntity{

    NewLoansResponseModel({
        required super.summary,
        required super.cronograma,
    });

    factory NewLoansResponseModel.fromJson(Map<String, dynamic> json) => NewLoansResponseModel(
        summary: SummaryModel.fromJson(json["summary"]),
        cronograma: List<CronogramaModel>.from(json["cronograma"].map((x) => CronogramaModel.fromJson(x))),
    );
}

class CronogramaModel  extends CronogramaEntity{

    CronogramaModel({
        required super.installmentNumber,
        required super.dueDate,
        required super.status,
        required super.principal,
        required super.interest,
        required super.totalInstallment,
    });

    factory CronogramaModel.fromJson(Map<String, dynamic> json) => CronogramaModel(
        installmentNumber: json["installment_number"],
        dueDate: DateTime.parse(json["due_date"]),
        status: json["status"],
        principal: json["principal"].toDouble(),
        interest: (json["interest"] is int ? json["interest"].toDouble() : json["interest"]),
        totalInstallment: json["total_installment"].toDouble(),
    );
}

class SummaryModel extends SummaryEntity {

    SummaryModel({
        required super.amount,
        required super.totalInterest,
        required super.totalPayable,
        required super.termMonths,
        required super.monthlyInstallment,
    });

    factory SummaryModel.fromJson(Map<String, dynamic> json) => SummaryModel(
        amount: json["amount"].toDouble(),
        totalInterest: json["total_interest"].toDouble(),
        totalPayable: json["total_payable"].toDouble(),
        termMonths: (json["term_months"] is int ? json["term_months"] : json["term_months"].toInt()),
        monthlyInstallment: json["monthly_installment"].toDouble(),
    );
}
