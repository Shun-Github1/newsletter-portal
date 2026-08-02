import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsletter_portal/core/constants/api_constants.dart';

class AppException implements Exception {
  final int code;
  final String message;
  AppException(this.code, this.message);
  
  @override
  String toString() => 'AppException: $code - $message';
}

final dioClientProvider = Provider<DioClient>((ref) {
  throw UnimplementedError('dioClientProvider must be overridden in ProviderScope');
});

class DioClient {
  late final Dio _dio;
  late final CookieJar _cookieJar;
  String? _webCsrfToken;

  Dio get dio => _dio;

  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      extra: kIsWeb ? {'withCredentials': true} : {},
    ));
  }

  Future<void> init() async {
    if (kIsWeb) {
      _cookieJar = CookieJar();
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      final cookiePath = '${appDocDir.path}/.cookies/';
      _cookieJar = PersistCookieJar(
        ignoreExpires: true,
        storage: FileStorage(cookiePath),
      );
      _dio.interceptors.add(CookieManager(_cookieJar));
    }
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.method == 'POST' || options.method == 'PUT' || options.method == 'DELETE') {
          if (kIsWeb) {
            if (_webCsrfToken != null) {
              options.headers['X-CSRF-TOKEN'] = _webCsrfToken;
            }
          } else {
            final cookies = await _cookieJar.loadForRequest(options.uri);
            final csrfCookie = cookies.where((c) => c.name == 'csrf_token').firstOrNull;
            if (csrfCookie != null) {
              options.headers['X-CSRF-TOKEN'] = csrfCookie.value;
            }
          }
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final data = responseData['data'];
          if (data is Map<String, dynamic> && data['csrf_token'] != null) {
            _webCsrfToken = data['csrf_token'] as String;
          }
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          // Trigger re-auth logic
        }
        return handler.next(e);
      }
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj.toString()),
    ));
  }

  Future<T> request<T>({
    required String path,
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
  }) async {
    try {
      final res = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options ?? Options(method: method),
      );

      final responseData = res.data;
      if (responseData is Map<String, dynamic>) {
        final code = responseData['code'] as int?;
        final msg = responseData['msg'] as String?;
        final payload = responseData['data'];

        if (code != 200 && code != 0 && code != null) {
          throw AppException(code, msg ?? 'Unknown error');
        }

        return payload as T;
      }
      return responseData as T;
    } on DioException catch (e) {
      throw AppException(e.response?.statusCode ?? -1, e.message ?? 'Network error');
    }
  }
}
