/*
import 'package:flutter/material.dart';

class BaseApiClient {
  late Dio api;
  late DateTime _startedAt;
  final Map<Type, dynamic> decoders = {};
  final BaseApiOption baseApiOption = BaseApiOption();
  final String baseUrl = '';

  BaseApiClient(BuildContext? context) {
    _init();
  }

  void _init() {
    final baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(minutes: baseApiOption.connectTimeout),
      receiveTimeout: Duration(minutes: baseApiOption.receiveTimeout),
      headers: baseApiOption.headers,
    );
    api = Dio(baseOptions);
  }

  _morphJsonResponse<T>(dynamic json) {
    BaseApiResponse defaultResponse = BaseApiResponse<T>.fromJson(
      json,
      decoders,
      type: T,
    );
    return defaultResponse.data;
  }

  BaseApiException handleResponseType(DioException error) {
    late String key;
    late String message;

    if (error.response!.data is Map) {
      key = error.response!.data['key'];
      message = error.response!.data['message'];
    } else {
      key = DioExceptionKey.unexpected;
      message = 'Agregar error';
    }

    return BaseApiException(key: key, message: message);
  }

  BaseApiException _onError(DioException dioError) {
    return BaseApiException.dioError(
      dioError: dioError,
      handleResponseType: handleResponseType,
    );
  }

  Future<T?> network<T>({
    required Function(Dio api) request,
    Function(DateTime startetAt, Response response)? handleSuccess,
    Function(DateTime startetAt, BaseApiException exception)? handleFailure,
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
}
*/
