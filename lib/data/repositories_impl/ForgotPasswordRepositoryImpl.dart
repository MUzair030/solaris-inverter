import 'package:dio/dio.dart';
import 'package:threepol_inverter_flutter/core/network/api_endpoints.dart';
import 'package:threepol_inverter_flutter/data/models/ForgotPasswordModel.dart';

import '../../core/network/dio_client.dart';
import '../../domain/entities/ForgotPasswordResponse.dart';
import '../../domain/repositories/ForgotPasswordRepository.dart';
import '../models/ForgotPasswordRequest.dart';
import '../models/ForgotPasswordResponseModel.dart';

class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  final DioClient _dioClient;

  ForgotPasswordRepositoryImpl(this._dioClient);

  @override
  Future<ForgotPasswordResponse> changePassword(
      ForgotPasswordRequest request) async {
    try {
      final response = await _dioClient.put1(
        ApiEndpoints.forgotpassword,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final resModel = ForgotPasswordResponseModel.fromJson(response.data);
        // return ForgotPasswordResponse(message: resModel.message);
        return resModel.toEntity();
      } else {
        throw Exception('Unexpected error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Unknown error');
    }
  }
}
