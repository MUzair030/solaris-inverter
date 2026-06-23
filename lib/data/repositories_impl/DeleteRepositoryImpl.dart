import 'package:dio/dio.dart';

import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../domain/repositories/DeleteRepository.dart';
import '../models/DeleteResponse.dart';

class DeleteRepositoryImpl implements DeleteRepository {
  final DioClient dioClient = DioClient();

  @override
  Future<DeleteResponse> deleteDevice(int deviceId) async {
    try {
      final response = await dioClient.dio.delete(
        ApiEndpoints.deletedevice,
        queryParameters: {"deviceId": deviceId},
      );

      if (response.statusCode == 200) {
        return DeleteResponse.fromJson(response.data);
      } else {
        throw Exception("Failed to delete device");
      }
    } on DioException catch (e) {
      throw dioClient.handleDioError(e);
    }
  }
}
