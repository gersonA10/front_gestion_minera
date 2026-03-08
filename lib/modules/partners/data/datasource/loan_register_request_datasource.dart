import 'package:front_gestion_minera/core/networking/http_services.dart';
import '../models/model.dart';

class LoanRegisterRequestDatasource {
  final ApiClient apiClient;
  LoanRegisterRequestDatasource({required this.apiClient});

  Future<LoanRegisterResponseModel> loanRegisterResquest(
    LoanRequestModel requestModel,
  ) async {
    final response = await apiClient.postFormData(
      '/api/loans/register',
      operationName: 'loan register',
      data: requestModel.toFormDataMap(),
      files: [
        {
          'loan_type': requestModel.loanType,
          'amount_or_quantity': requestModel.amountOrQuantity,
          'description': requestModel.description,
          'comprobante_img': requestModel.comprobanteImg,
        },
      ],
    );
    return LoanRegisterResponseModel.fromJson(response);
  }
}
