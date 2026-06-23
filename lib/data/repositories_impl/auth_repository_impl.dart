import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../utils/SharedPreferencesHelper.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/LoginRequestModel.dart';
import '../models/LoginResponseModel.dart';
import '../models/signup_request_model.dart';
import '../models/signup_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;

  AuthRepositoryImpl(this._dioClient);

  @override
  Future<SignupResponseModel> signup(SignupRequestModel request) async {
    try {
      final response =
          await _dioClient.post(ApiEndpoints.signup, data: request.toJson());

      if (response.statusCode == 200) {
        return SignupResponseModel.fromJson(response.data);
      } else {
        final message = _extractErrorMessage(response.data);
        throw Exception(message);
        // throw Exception(response.data['message'] ?? 'Signup failed');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Extract error message from API response
        // final errorMessage = e.response?.data['message'] ?? 'An error occurred';
        // throw Exception(errorMessage);
        final message = _extractErrorMessage(e.response?.data);
        throw Exception(message);
      } else {
        throw Exception("Network Error: Please check your connection.");
      }
    }
  }

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response =
          await _dioClient.post(ApiEndpoints.signin, data: request.toJson());

      // CASE 1: Backend returned error as plain STRING
      if (response.data is String) {
        throw Exception(response.data);
      }

      // CASE 2: Backend returned valid JSON
      if (response.data is Map<String, dynamic>) {
        final loginResponse = LoginResponseModel.fromJson(response.data);

        await SharedPreferencesHelper.saveLoginData(
          loginResponse.id,
          loginResponse.username,
          loginResponse.email,
          request.password,
          loginResponse.token,
        );

        return loginResponse;
      }

      throw Exception("Unexpected response from server");
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;

        // 🔹 String error
        if (data is String) {
          throw Exception(data);
        }

        // 🔹 JSON error
        if (data is Map && data['message'] != null) {
          throw Exception(data['message']);
        }
      }

      throw Exception("Network error. Please try again.");
    }
  }

  // @override
  // Future<LoginResponseModel> login(LoginRequestModel request) async {
  //   try {
  //     final response =
  //         await _dioClient.post(ApiEndpoints.signin, data: request.toJson());
  //
  //     if (response.statusCode == 200) {
  //       final loginResponse = LoginResponseModel.fromJson(response.data);
  //
  //       await SharedPreferencesHelper.saveLoginData(
  //         loginResponse.id,
  //         loginResponse.username,
  //         loginResponse.email,
  //         request.password,
  //         loginResponse.token,
  //       );
  //
  //       return loginResponse;
  //     } else {
  //       final message = _extractErrorMessage(response.data);
  //       throw Exception(message);
  //       // throw Exception('Login failed: ${response.data['message']}');
  //     }
  //   } on DioException catch (e) {
  //     if (e.response != null) {
  //       // 🔹 Case 1: Backend returns plain string
  //       if (e.response!.data is String) {
  //         throw Exception(e.response!.data);
  //       }
  //
  //       // // 🔹 Case 2: Backend returns JSON with message
  //       // if (e.response!.data is Map &&
  //       //     e.response!.data['message'] != null) {
  //       //   throw Exception(e.response!.data['message']);
  //       // }
  //     }
  //
  //     throw Exception("Something went wrong");
  //   }
  //   // catch (e) {
  //   //   final message = e is DioException && e.response != null
  //   //       ? _extractErrorMessage(e.response?.data)
  //   //       : 'Login failed';
  //   //   throw Exception(message);
  //   //   // throw Exception('Login error: $e');
  //   // }
  // }

  String _extractErrorMessage(dynamic data) {
    final message = data?['message'];

    if (message is List && message.isNotEmpty) {
      return message.first.toString();
    } else if (message is Map) {
      // if 'message' is a map like {email: ["Email already exists"]}
      final firstKey = message.keys.first;
      final value = message[firstKey];
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }
      return value.toString();
    } else if (message is String) {
      return message;
    } else {
      return 'An unexpected error occurred';
    }
  }
}
