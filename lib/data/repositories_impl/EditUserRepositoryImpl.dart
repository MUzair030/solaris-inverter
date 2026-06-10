import 'package:dio/dio.dart';

import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../domain/repositories/EditUserRepository.dart';
import '../models/EditUserRequestModel.dart';
import '../models/EditUserResponseModel.dart';

class EditUserRepositoryImpl implements EditUserRepository {
  final DioClient _dioClient = DioClient();

  @override
  Future<EditUserResponseModel> editUser(
      EditUserRequestModel requestModel) async {
    try {
      final response = await _dioClient.put1(
        ApiEndpoints.edituser,
        data: requestModel.toJson(),
      );

      // Use the flexible factory constructor to handle response
      return EditUserResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _dioClient.handleDioError(e);
    } catch (e) {
      // Catch any other errors and convert them to a readable message
      throw Exception('Unexpected error: $e');
    }
  }

  // @override
  // Future<EditUserResponseModel> editUser(
  //     EditUserRequestModel requestModel) async {
  //   try {
  //     final response = await _dioClient.dio.put(
  //       ApiEndpoints.edituser,
  //       data: requestModel.toJson(),
  //     );
  //
  //     // Handle both Map and plain string response
  //     if (response.data is String) {
  //       return EditUserResponseModel(message: response.data);
  //     } else if (response.data is Map<String, dynamic>) {
  //       return EditUserResponseModel.fromJson(response.data);
  //     } else {
  //       throw Exception("Unexpected response type");
  //     }
  //   } on DioException catch (e) {
  //     throw _dioClient.handleDioError(e);
  //   }
  // }
}
