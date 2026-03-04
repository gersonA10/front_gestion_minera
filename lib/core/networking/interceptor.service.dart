import 'package:dio/dio.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';

class InterceptorService extends Interceptor {
  final Dio _dio;

  InterceptorService(this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await UserSession.getAccessToken();
    if (token.isNotEmpty && !options.headers.containsKey('Authorization')) {
      options.headers.addAll(
        {'Authorization': 'Bearer $token'},
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      if (int.parse(err.response?.statusCode.toString() ?? '0') == 401) {
        //TODO: Refresh token logic here
        // String newAccessToken = await refreshToken();
        // err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        return handler.resolve(await _retry(err.requestOptions));
      } else {
        return handler.next(err);
      }
    } catch (error) {
      return handler.next(err);
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // Future<String> refreshToken() async {
  //   try {
  //     final refreshToken = await UserSession.getRefreshToken();
  //     final url = dotenv.env['API_BASE_URL']!;
  //     if (refreshToken.isEmpty) {
  //       throw 'No exit refresh token';
  //     }
  //     final response = await Dio().post(
  //       '${url}auth/refresh',
  //       options: Options(
  //         headers: {'Authorization': 'Bearer $refreshToken'},
  //       ),
  //     );

  //     final signModel = SignResponseModel.fromJson(response.data);
  //     await UserSession.setAccessToken(
  //       signModel.accessToken,
  //     );
  //     await UserSession.setRefreshToken(
  //       signModel.refreshToken,
  //     );
  //     return signModel.accessToken;
  //   } catch (error) {
  //     throw 'error: refresh token';
  //   }
  // }
}
