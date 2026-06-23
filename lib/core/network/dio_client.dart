import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../utils/SharedPreferencesHelper.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio _dio;
  bool _isInitialized = false;

  factory DioClient() => _instance;

  DioClient._internal();

  /// **Call this first before using DioClient**
  Future<void> init() async {
    await _initializeDio();
    _isInitialized = true;
  }

  // Future<void> _initializeDio() async {
  //   String? token = await SharedPreferencesHelper.getToken();
  //
  //   // Fluttertoast.showToast(msg: "$token");
  //
  //   _dio = Dio(
  //     BaseOptions(
  //       baseUrl: 'http://db.3pol.com:24301/api/',
  //       connectTimeout: const Duration(seconds: 30),
  //       receiveTimeout: const Duration(seconds: 30),
  //       // sendTimeout: const Duration(seconds: 15),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         // if (token != null) 'Authorization': 'Bearer $token',
  //         // if (token != null) 'Authorization': token,
  //         if (token != null && token.isNotEmpty) 'Authorization': token,
  //       },
  //     ),
  //   );
  //
  //   print("✅ Dio Initialized with Token: $token");
  // }

  Future<void> _initializeDio() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://db.3pol.com:24301/api/',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Token Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await SharedPreferencesHelper.getToken();
          debugPrint(
              "Dio Request: Fetching Token: ${token != null ? 'Present' : 'NULL'}");
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = token;
          }
          return handler.next(options);
        },
        // 🔴 Handle 401 Unauthorized globally
        // onError: (DioException e, handler) async {
        //   if (e.response?.statusCode == 401) {
        //     await SharedPreferencesHelper.logout(); // clear old token
        //     Fluttertoast.showToast(msg: "Session expired. Please login again.");
        //
        //     await refreshToken();
        //     // Navigator.pushReplacement(
        //     //   context,
        //     //   MaterialPageRoute(
        //     //       builder: (context) => LoginScreen()),
        //     // );
        //     // OPTIONAL: Redirect to login screen if needed
        //     // You can pass a global navigatorKey to handle navigation here
        //   }
        //   return handler.next(e);
        // },
      ),
    );
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
    // Logging (optional, for development)
    // _dio.interceptors.add(LogInterceptor(
    //   requestBody: true,
    //   responseBody: true,
    // ));

    print("✅ Dio Initialized");
  }

  /// **Ensure Dio is initialized before usage**
  Dio get dio {
    if (!_isInitialized) {
      throw Exception("DioClient not initialized. Call `init()` first.");
    }
    return _dio;
  }

  /// **Refresh Dio with the latest token**
  Future<void> refreshToken() async {
    await _initializeDio(); // Re-fetch latest token and update Dio instance
  }

  Future<Response> put(String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    await _checkInitialization();
    return await _dio.put(endpoint, queryParameters: queryParams);
  }

  Future<Response> put1(String endpoint,
      {Map<String, dynamic>? queryParams, dynamic data}) async {
    await _checkInitialization();
    return await _dio.put(endpoint, queryParameters: queryParams, data: data);
  }

  Future<Response> post(String endpoint, {dynamic data}) async {
    await _checkInitialization();
    return await _dio.post(endpoint, data: data);
  }

  Future<String> getPlainText(String path,
      {Map<String, dynamic>? queryParams}) async {
    await _checkInitialization(); // ADD THIS LINE 👇
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParams,
        options: Options(responseType: ResponseType.plain), // ✅ fix here
      );
      return response.data.toString();
    } on DioException catch (e) {
      // print("❌ DioException: ${e.type}");
      // print("❌ Dio Error Message: ${e.message}");
      // print("❌ Dio Error Response: ${e.response}");
      // print("❌ Dio Error Data: ${e.response?.data}");
      // print("❌ Dio Error StackTrace: ${e.stackTrace}");
      // print("❌ Dio Error Request: ${e.requestOptions}");

      throw Exception("Dio Error: ${e.message ?? 'No message'}");
      // throw Exception("Dio Error: ${e.message}");
    }
  }

  Future<Response> get(String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    await _checkInitialization();
    try {
      return await _dio.get(endpoint, queryParameters: queryParams);
    } on DioException catch (e) {
      print("❌ Dio Network Error: ${e.message}");
      throw handleDioError(e);
    }
  }

  Future<Response> getotp(String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    // await _checkInitialization();
    if (!_isInitialized) await init();
    try {
      return await _dio.get(endpoint, queryParameters: queryParams);
    } on DioException catch (e) {
      print("❌ Dio Network Error: ${e.message}");
      throw handleDioError(e);
    }
  }

  Future<Response> delete(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        url,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );
      return response;
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  /// **Ensure Dio is initialized before any request**
  Future<void> _checkInitialization() async {
    if (!_isInitialized) await init();
  }

  Exception handleDioError(DioException e) {
    if (e.response != null) {
      print("❌ Dio Error Response: ${e.response?.data}");
    } else {
      print("❌ Dio Network Error: ${e.message}");
    }

    if (e.response != null) {
      switch (e.response?.statusCode) {
        case 400:
          return Exception("Bad Request: ${e.response?.data['message']}");
        case 401:
          return Exception(
              "Unauthorized: Please check your login credentials.");
        case 403:
          return Exception("Forbidden: You don't have permission.");
        case 404:
          return Exception("Not Found: The requested resource is unavailable.");
        case 500:
          return Exception("Server Error: Try again later.");
        default:
          return Exception(
              "Error: ${e.response?.data['message'] ?? 'Unknown error'}");
      }
    } else {
      return Exception("Network Error: Please check your connection.");
    }
  }
}
