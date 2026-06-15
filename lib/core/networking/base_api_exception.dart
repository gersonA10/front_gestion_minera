import 'package:dio/dio.dart';

class DioExceptionKey {
  static const cancelRequest = 'dio_cancel_request';
  static const connectTimeout = 'dio_connect_timeout';
  static const receiveTimeout = 'dio_receive_timeout';
  static const sendTimeout = 'dio_send_timeout';
  static const response = 'dio_response';
  static const offline = 'dio_offline';
  static const unexpected = 'dio_unexpected';
  static const unknown = 'dio_unknown';
  static const unauthorised = 'dio_unauthorized';
}

class BaseApiException implements Exception {
  final String key;
  final String message;
  final DioExceptionType type;
  final RequestOptions requestOptions;
  final StackTrace? stackTrace;
  final Response? response;
  final String? detail;

  BaseApiException({
    required this.key,
    required this.message,
    required this.type,
    required this.requestOptions,
    this.stackTrace,
    this.response,
    this.detail,
  });

  factory BaseApiException.fromDioError({
    required DioException dioError,
    BaseApiException Function(DioException dioError)? handleResponseType,
  }) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        return BaseApiException(
          key: DioExceptionKey.cancelRequest,
          message: 'Request to API server was cancelled',
          requestOptions: dioError.requestOptions,
          type: DioExceptionType.cancel,
          stackTrace: dioError.stackTrace,
        );
      case DioExceptionType.connectionTimeout:
        return BaseApiException(
          key: DioExceptionKey.connectTimeout,
          message:
              'Tu solicitud no pudo ser procesada. \nPor favor, intenta nuevamente.',
          requestOptions: dioError.requestOptions,
          type: DioExceptionType.connectionTimeout,
          stackTrace: dioError.stackTrace,
        );
      case DioExceptionType.receiveTimeout:
        return BaseApiException(
          key: DioExceptionKey.receiveTimeout,
          message: 'Receive timeout in connection with API server',
          requestOptions: dioError.requestOptions,
          type: DioExceptionType.receiveTimeout,
          stackTrace: dioError.stackTrace,
        );
      case DioExceptionType.sendTimeout:
        return BaseApiException(
          key: DioExceptionKey.sendTimeout,
          message: 'Send timeout in connection with API server',
          requestOptions: dioError.requestOptions,
          type: DioExceptionType.sendTimeout,
          stackTrace: dioError.stackTrace,
        );
      case (DioExceptionType.badResponse):
        if (handleResponseType != null) return handleResponseType(dioError);
        return BaseApiException(
          key: DioExceptionKey.response,
          message:
              'DioError ${DioExceptionType.badResponse}: ${dioError.error}',
          requestOptions: dioError.requestOptions,
          type: DioExceptionType.badResponse,
          response: dioError.response,
        );
      case (DioExceptionType.connectionError):
        if (dioError.message?.contains('SocketException') ?? false) {
          return BaseApiException(
            key: DioExceptionKey.offline,
            message: 'No Internet',
            requestOptions: dioError.requestOptions,
            type: DioExceptionType.connectionError,
            stackTrace: dioError.stackTrace,
          );
        } else {
          return BaseApiException(
            key: DioExceptionKey.unexpected,
            message: 'Unexpected error occurred',
            requestOptions: dioError.requestOptions,
            type: DioExceptionType.connectionError,
            stackTrace: dioError.stackTrace,
          );
        }
      default:
        return BaseApiException(
          key: DioExceptionKey.unknown,
          message: 'Something went wrong',
          requestOptions: dioError.requestOptions,
          type: DioExceptionType.unknown,
          stackTrace: dioError.stackTrace,
        );
    }
  }

  @override
  String toString() {
    final status = response?.statusCode;
    return [
      message,
      if (status != null) '(HTTP $status)',
      if (detail != null && detail!.isNotEmpty) '- $detail',
    ].join(' ');
  }
}
