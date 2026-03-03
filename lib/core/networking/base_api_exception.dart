/*
class DioExceptionKey {
  static const unauthorized = 'dio_unauthorized';
  static const cancelRequest = 'dio_cancel_request';
  static const connectTimeout = 'dio_connect_timeout';
  static const receiveTimeout = 'dio_receive_timeout';
  static const sendTimeout = 'dio_send_timeout';
  static const response = 'dio_response';
  static const offline = 'dio_offline';
  static const unexpected = 'dio_unexpected';
  static const unknown = 'dio_unknown';
  static const apiLogicError = 'api_logic_error';
}

class BaseApiException implements Exception {
  final String key;
  final String message;

  const BaseApiException({required this.key, required this.message});

  factory BaseApiException.dioError({
    required DioException dioError,
    BaseApiException Function(DioException dioError)? handleResponseType,
  }) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        return BaseApiException(
          key: DioExceptionKey.apiLogicError,
          message: "La peticion a la Api fue cancelada",
        );
      case DioExceptionType.connectionTimeout:
        return BaseApiException(
          key: DioExceptionKey.connectTimeout,
          message:
              "Tu solicitud no pudo ser procesada.\nPor favor intente nuevamente",
        );
      case DioExceptionType.receiveTimeout:
        return BaseApiException(
          key: DioExceptionKey.receiveTimeout,
          message: "Tiempo de espera agotado",
        );
      case DioExceptionType.sendTimeout:
        return BaseApiException(
          key: DioExceptionKey.sendTimeout,
          message: "Tiempo de envio expirado",
        );
      case DioExceptionType.badResponse:
        if (handleResponseType != null) return handleResponseType(dioError);
        return BaseApiException(
          key: DioExceptionKey.response,
          message:
              "dioError ${DioExceptionType.badResponse}: ${dioError.error}",
        );
      case DioExceptionType.connectionError:
        if (dioError.message?.contains("SocketException") ?? false) {
          return BaseApiException(
            key: DioExceptionKey.offline,
            message: "No hay internet",
          );
        } else {
          return BaseApiException(
            key: DioExceptionKey.unexpected,
            message: "Error inesperado",
          );
        }
      default:
        return BaseApiException(
          key: DioExceptionKey.unknown,
          message: "Ocurrio un error",
        );
    }
  }
}
*/
