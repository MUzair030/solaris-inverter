import 'package:dio/dio.dart';
import 'package:threepol_inverter_flutter/core/network/api_endpoints.dart';

import '../../core/network/dio_client.dart';
import '../../domain/repositories/ChangePasswordRepository.dart';
import '../models/ChangePasswordModel.dart';
import '../models/ChangePasswordResponseModel.dart';

class ChangePasswordRepositoryImpl implements ChangePasswordRepository {
  final DioClient _dioClient;

  ChangePasswordRepositoryImpl(this._dioClient);

  @override
  Future<ChangePasswordResponseModel> changePassword(
      ChangePasswordModel model) async {
    try {
      final response = await _dioClient.put1(
        ApiEndpoints.changepassword,
        data: model.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          return ChangePasswordResponseModel.fromJson(data);
        } else if (data is String) {
          return ChangePasswordResponseModel(message: data);
        } else {
          throw Exception("Unexpected response format.");
        }
      } else {
        throw Exception("Failed to change password");
      }
      // return ChangePasswordResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _dioClient.handleDioError(e);
    }
  }
}
