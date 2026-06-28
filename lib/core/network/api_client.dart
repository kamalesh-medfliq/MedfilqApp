import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  
  late Dio dio;
  final _storage = const FlutterSecureStorage();

  // Use 10.0.2.2 for Android emulator, localhost for iOS simulator/Web.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Auth Interceptor: Attach JWT Token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip adding token for login and registration endpoints
          if (!options.path.contains('/auth/login') && 
              !options.path.contains('/auth/register')) {
            final token = await _storage.read(key: 'jwt_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
      ),
    );

    // Simple logging interceptor for debugging during development
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('DIO Request: ${options.method} ${options.uri}');
          if (options.data != null) {
            debugPrint('DIO Request Data: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('DIO Response: [${response.statusCode}] ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('DIO Error: [${e.response?.statusCode}] ${e.message}');
          if (e.response?.data != null) {
            debugPrint('DIO Error Data: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
  }
}

