import 'package:dio/dio.dart';
import 'package:threepol_inverter_flutter/core/network/api_endpoints.dart';

import '../../core/network/dio_client.dart';
import '../../domain/entities/geyser_history_data_entity.dart';
import '../../domain/repositories/geyser_history_repository.dart';
import '../models/geyser_history_request_model.dart';
import '../models/geyser_history_response_model.dart';

class GeyserHistoryRepositoryImpl implements GeyserHistoryRepository {
  final DioClient dioClient;

  GeyserHistoryRepositoryImpl(this.dioClient);

  @override
  Future<List<GeyserHistoryResponseModel>> fetchGeyserData(
      GeyserHistoryRequestModel request) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.getAllInverterData,
        queryParams: request.toQueryParams(),
      );

      //   if (response.statusCode == 200) {
      //     final dataList = response.data as List<dynamic>;
      //     return dataList
      //         .map((e) => GeyserHistoryResponseModel.fromJson(e))
      //         .toList();
      //   } else {
      //     throw Exception('Failed to load inverter data');
      //   }
      // } on DioError catch (e) {
      //   throw Exception('Network error: ${e.message}');
      // } catch (e) {
      //   throw Exception('Unexpected error: $e');
      // }

      if (response.statusCode == 200 && response.data is List) {
        List<dynamic> data = response.data;
        return data
            .map((json) => GeyserHistoryResponseModel.fromJson(json))
            .toList();
      } else {
        throw Exception("Invalid API response");
      }
    } catch (e) {
      throw Exception('Failed to fetch inverter data: $e');
    }
    // if (response.statusCode == 200 && response.data is List) {
    //   return GeyserHistoryResponseModel.fromJsonList(response.data);
    // } else {
    //   throw Exception('Failed to fetch geyser data');
    // }
  }
}
