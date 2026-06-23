import 'package:dio/dio.dart';
import 'package:threepol_inverter_flutter/domain/repositories/main_inverter_repository.dart';

import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../models/inverter_data_model.dart';

// class MainInverterRepositoryImpl implements MainInverterRepository {
//   final DioClient _dioClient;
//
//   MainInverterRepositoryImpl(this._dioClient);
//
//   // @override
//   // Future<List<InverterDataModel>> fetchInverterData(String macAddress) async {
//   //   try {
//   //     final response = await _dioClient.dio.get(
//   //       ApiEndpoints.getAllInverterData,
//   //       queryParameters: {
//   //         "macAddress": "48:27:e2:83:62:24",
//   //         "perday": true, // Fetching today's data first
//   //         "perweekl": false,
//   //         "permonthy": false,
//   //         "peryear": false,
//   //         "completereport": false,
//   //       },
//   //     );
//   //
//   //     List<dynamic> data = response.data;
//   //     if (data.isNotEmpty) {
//   //       return data.map((json) => InverterDataModel.fromJson(json)).toList();
//   //     } else {
//   //       return fetchLastAvailableData(macAddress);
//   //     }
//   //   } catch (e) {
//   //     return fetchLastAvailableData(macAddress);
//   //   }
//   // }
//
//   @override
//   Future<List<InverterDataModel>> fetchInverterData(String macAddress) async {
//     try {
//       await _dioClient.init();
//       final response = await _dioClient.dio.put(
//         ApiEndpoints.getAllInverterData,
//         queryParameters: {
//           "macAddress": macAddress,
//           "perday": false,
//           "perweekl": false,
//           "permonthy": false,
//           "peryear": false,
//           "completereport": true,
//         },
//       );
//
//       List<dynamic> data = response.data;
//       List<InverterDataModel> inverterData =
//           data.map((json) => InverterDataModel.fromJson(json)).toList();
//
//       // Sort data by timestamp (latest first)
//       inverterData.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//
//       print("inverter data: $data ${inverterData}");
//
//       return inverterData;
//     } on DioException catch (e) {
//       throw _dioClient.handleDioError(e);
//     } catch (e) {
//       throw Exception("Failed to fetch inverter data: $e");
//     }
//   }
//
//   Future<List<InverterDataModel>> fetchLastAvailableData(
//       String macAddress) async {
//     try {
//       final response = await _dioClient.dio.get(
//         ApiEndpoints.getAllInverterData,
//         queryParameters: {
//           "macAddress": "48:27:e2:83:62:24",
//           "perday": false,
//           "perweekl": false,
//           "permonthy": false,
//           "peryear": false,
//           "completereport": true,
//         },
//       );
//
//       List<dynamic> data = response.data;
//       return data.map((json) => InverterDataModel.fromJson(json)).toList();
//     } catch (e) {
//       throw Exception('Failed to fetch inverter data: $e');
//     }
//   }
// }

class MainInverterRepositoryImpl implements MainInverterRepository {
  final DioClient _dioClient;

  MainInverterRepositoryImpl(this._dioClient);

  @override
  Future<List<InverterDataModel>?> fetchInverterData(String macAddress) async {
    try {
      Response response = await _dioClient.dio.get(
        "inverter/getAllInverterData",
        queryParameters: {"macAddress": "48:27:e2:83:62:24"},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => InverterDataModel.fromJson(json)).toList();
      } else {
        return null;
      }
    } on DioException catch (e) {
      print("Error fetching inverter data: ${e.message}");
      return null;
    } catch (e) {
      throw Exception('Failed to fetch inverter data');
    }
  }

  // @override
  // Future<List<InverterDataModel>> fetchInverterData(String macAddress) async {
  //   try {
  //     final response = await _dioClient.dio
  //         .get('inverter/getAllInverterData', queryParameters: {
  //       'macAddress': macAddress,
  //       'completereport': true,
  //     });
  //
  //     return (response.data as List)
  //         .map((json) => InverterDataModel.fromJson(json))
  //         .toList();
  //   } catch (e) {
  //     throw Exception('Failed to fetch inverter data');
  //   }
  // }

  // @override
  // Future<List<InverterDataModel>> fetchInverterData(String macAddress) async {
  //   try {
  //     final response = await _dioClient.dio.get(
  //       ApiEndpoints.getAllInverterData,
  //       queryParameters: {
  //         "macAddress": macAddress,
  //         "perday": false,
  //         "perweekl": false,
  //         "permonthy": false,
  //         "peryear": false,
  //         "completereport": true,
  //       },
  //     );
  //
  //     List<dynamic> data = response.data;
  //     return data.map((json) => InverterDataModel.fromJson(json)).toList();
  //   } catch (e) {
  //     throw Exception('Failed to fetch inverter data: $e');
  //   }
  // }
}
