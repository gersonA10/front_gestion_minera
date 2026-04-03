import '../../../domain/entity/entity.dart';

class ApplyForALoanResponseModel extends ApplyForALoanResponseEntity{


    ApplyForALoanResponseModel({
        required super.loanId,
        required super.loanCode,
    });
     factory ApplyForALoanResponseModel.fromJson(Map<String, dynamic> json) => ApplyForALoanResponseModel(
        loanId: json["loan_id"],
        loanCode: json["loan_code"],
    );

}
