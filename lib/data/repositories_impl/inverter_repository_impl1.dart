import 'package:dio/dio.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../domain/repositories/inverter_repository1.dart';
import '../models/inverter_request_model.dart';
import '../models/inverter_response_model.dart';

class InverterRepositoryImpl1 implements InverterRepository1 {
  final DioClient _dioClient;

  InverterRepositoryImpl1(this._dioClient);

  @override
  Future<List<InverterResponseModel>> fetchInverterData(
      InverterRequestModel request) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.getAllInverterData,
        queryParameters: request.toJson(),
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => InverterResponseModel.fromJson(e))
            .toList();
      } else {
        throw Exception("Invalid response format");
      }
    } on DioException catch (e) {
      throw Exception("Dio error: ${e.message}");
    } catch (e) {
      throw Exception("Failed to fetch inverter data: $e");
    }
  }
}
