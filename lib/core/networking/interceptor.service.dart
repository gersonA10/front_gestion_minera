import 'package:dio/dio.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';
import 'package:front_gestion_minera/utils/session/session_actions.dart';

class InterceptorService extends Interceptor {
  // ignore: unused_field
  final Dio _dio;

  InterceptorService(this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await UserSession.getAccessToken();
    if (token.isNotEmpty && !options.headers.containsKey('Authorization')) {
      options.headers.addAll({'Authorization': token});
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await SessionActions.logout(true);
      return handler.next(err);
    } 
    
    return handler.next(err);
  }
}