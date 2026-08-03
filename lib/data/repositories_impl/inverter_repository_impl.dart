import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:threepol_inverter_flutter/core/network/dio_client.dart';
import 'package:threepol_inverter_flutter/data/models/inverter_data_model.dart';
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
          "perweek": false,
          "permonth": false,
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
        "perweek": false,
        "permonth": false,
        "peryear": false,
        "completereport": false,
      };

      switch (filter) {
        case "daily":
          queryParams["perday"] = true;
          break;
        case "weekly":
          queryParams["perweek"] = true;
          break;
        case "monthly":
          queryParams["permonth"] = true;
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
}
