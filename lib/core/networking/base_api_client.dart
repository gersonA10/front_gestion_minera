import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/core/networking/base_api_option.dart';
import 'package:front_gestion_minera/core/networking/base_api_response.dart';

class BaseApiClient {
  late Dio api;
  late DateTime _startedAt;
  final BaseApiOption customBaseOptions = BaseApiOption();
  final String baseUrl = '';
  final Map<Type, Interceptor> interceptors = {};
  final Map<Type, dynamic> decoders = {};

  BaseApiClient(BuildContext? context) {
    _init();
  }

  /// Initialize class
  void _init() {
    final baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: customBaseOptions.connectTimeout),
      receiveTimeout: Duration(milliseconds: customBaseOptions.receiveTimeout),
      headers: customBaseOptions.headers,
    );

    api = Dio(baseOptions);
    if (interceptors.isNotEmpty) {
      _addInterceptors();
    }
  }

  /// Networking class to handle API requests
  /// Use the [request] callback to call an API
  /// [handleSuccess] overrides the response on a successful status code
  /// [handleFailure] is executed before the exception is thrown
  ///
  /// Usage:
  /// Future<List<User>?> fetchUsers() async {
  ///     return await network<List<User>>(
  ///         request: (request) => request.get("/users"),
  ///     );
  ///   }
  Future<T?> network<T>({
    required Function(Dio api) request,
    Function(DateTime startetAt, Response response)? handleSuccess,
    Function(
      DateTime startetAt,
      BaseApiException exception,
    )? handleFailure,
  }) async {
    try {
      late final Response response;
      _startedAt = DateTime.now();
      response = await request(api);
      if (handleSuccess != null) {
        return await handleSuccess(_startedAt, response);
      }

      return T.toString() != 'dynamic'
          ? _morphJsonResponse<T>(response.data)
          : response.data;
    } on DioException catch (dioError) {
      final error = _onError(dioError);
      if (handleFailure != null) {
        await handleFailure(_startedAt, error);
      }

      throw error;
    }
  }

  /// Handle the [DioException] response if there is an issue.
  BaseApiException _onError(DioException dioError) {
    return BaseApiException.fromDioError(
      dioError: dioError,
      handleResponseType: handleResponseType,
    );
  }

  /// Overrites the response type error of dioError
  BaseApiException handleResponseType(DioException error) {
    late String key;
    late String message;
    String? detail;

    if (error.response!.data is Map) {
      key = error.response!.data['key'];
      message = error.response!.data['message'];
      detail = error.response!.data['detail'];
    } else {
      key = DioExceptionKey.unexpected;
      message = 'Agregar error';
    }

    return BaseApiException(
      key: key,
      message: message,
      type: error.type,
      requestOptions: error.requestOptions,
      stackTrace: error.stackTrace,
      response: error.response,
      detail: detail,
    );
  }

  /// Display a error to the user
  /// This method is only called if you provide the API service
  /// with a [BuildContext].
  displayError(DioException dioError, BuildContext context) {}

  /// Morphs json into Object using the 'config/api_decoders'.
  _morphJsonResponse<T>(dynamic json) {
    BaseApiResponse defaultResponse = BaseApiResponse<T>.fromJson(
      json,
      decoders,
      type: T,
    );
    return defaultResponse.data;
  }

  /// Adds all the [interceptors] to [dio].
  _addInterceptors() => api.interceptors.addAll(interceptors.values);
}
