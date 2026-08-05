import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:threepol_inverter_flutter/core/network/dio_client.dart';
import 'package:threepol_inverter_flutter/data/models/inverter_data_model.dart';
import 'package:threepol_inverter_flutter/data/models/inverter_stats_model.dart';
import 'package:threepol_inverter_flutter/domain/repositories/inverter_repository.dart';

import '../../../core/network/api_endpoints.dart';

class InverterRepositoryImpl implements InverterRepository {
  final DioClient _dioClient;

  InverterRepositoryImpl(this._dioClient);

  @override
  Future<List<InverterDataModel>> fetchInverterData(String macAddress) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.getAllInverterData,
        queryParameters: {
          "macAddress": macAddress,
          "perday": false,
          "perweekl": false,
          "permonthy": false,
          "peryear": false,
          "completereport": false,
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        List<dynamic> data = response.data;
        return data.map((json) => InverterDataModel.fromJson(json)).toList();
      } else {
        throw Exception("Invalid API response");
      }
    } catch (e) {
      throw Exception('Failed to fetch inverter data: $e');
    }
  }

  @override
  Future<List<InverterDataModel>> fetchInverterData1(
      String macAddress, String filter) async {
    try {
      Map<String, bool> queryParams = {
        "perday": false,
        "perweekl": false,
        "permonthy": false,
        "peryear": false,
        "completereport": false,
      };

      switch (filter) {
        case "daily":
          queryParams["perday"] = true;
          break;
        case "weekly":
          queryParams["perweekl"] = true;
          break;
        case "monthly":
          queryParams["permonthy"] = true;
          break;
        case "yearly":
          queryParams["peryear"] = true;
          break;
        default:
          queryParams["completereport"] = true;
      }

      final response = await _dioClient.dio.get(
        ApiEndpoints.getAllInverterData,
        queryParameters: {
          "macAddress": macAddress,
          ...queryParams,
        },
      );

      // Fluttertoast.showToast(msg: "${queryParams}");

      List<dynamic> data = response.data;
      return data.map((json) => InverterDataModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch inverter data: $e');
    }
  }

  @override
  Future<List<InverterStatsBucket>> fetchInverterStats(
    String macAddress, {
    required String groupBy,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.inverterStats,
        queryParameters: {
          "macAddress": macAddress,
          "groupBy": groupBy,
          if (startDate != null) "startDate": startDate,
          if (endDate != null) "endDate": endDate,
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        List<dynamic> data = response.data;
        return data.map((json) => InverterStatsBucket.fromJson(json)).toList();
      } else {
        throw Exception("Invalid API response");
      }
    } catch (e) {
      throw Exception('Failed to fetch inverter stats: $e');
    }
  }

  @override
  Future<InverterDataModel?> fetchLatestInverterData(String macAddress) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.inverterLatest,
        queryParameters: {"macAddress": macAddress},
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data is Map<String, dynamic> &&
          (response.data as Map).isNotEmpty) {
        return InverterDataModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch latest inverter data: $e');
    }
  }
}
