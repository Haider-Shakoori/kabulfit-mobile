import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/app_config.dart';
import '../security/token_store.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({required AppConfig config, required TokenStore tokenStore})
    : _tokenStore = tokenStore,
      _dio = Dio(
        BaseOptions(
          baseUrl: config.apiBaseUrl.toString().replaceFirst(RegExp(r'/$'), ''),
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
          headers: const {'Accept': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStore.read();
          final info = await PackageInfo.fromPlatform();
          options.headers.addAll({
            'Accept-Language': _supportedLocale(),
            'X-App-Version': info.version,
            if (token != null) 'Authorization': 'Bearer $token',
          });
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) await _tokenStore.clear();
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStore _tokenStore;

  Future<Map<String, dynamic>> get(String path) => _request('GET', path);

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) => _request('POST', path, data: data);

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final locale = _supportedLocale();
      final response = await _dio.request<Map<String, dynamic>>(
        '/$locale${path.startsWith('/') ? path : '/$path'}',
        data: data,
        options: Options(method: method),
      );
      return response.data ?? const {};
    } on DioException catch (error) {
      final body = error.response?.data;
      final map = body is Map<String, dynamic>
          ? body
          : const <String, dynamic>{};
      throw ApiException(
        map['message'] as String? ?? 'Unable to connect to KabulFit.',
        statusCode: error.response?.statusCode,
        validationErrors: _validationErrors(map['errors']),
      );
    }
  }

  String _supportedLocale() {
    final locale = PlatformDispatcher.instance.locale.languageCode;
    return const {'en', 'fa', 'ps'}.contains(locale) ? locale : 'en';
  }

  Map<String, List<String>>? _validationErrors(Object? value) {
    if (value is! Map) return null;
    return value.map(
      (key, item) => MapEntry(
        key.toString(),
        item is List
            ? item.map((entry) => entry.toString()).toList()
            : [item.toString()],
      ),
    );
  }
}
