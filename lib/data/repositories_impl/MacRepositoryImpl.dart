import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../domain/repositories/MacRepository.dart';
import '../models/MacResponseModel.dart';

class MacRepositoryImpl implements MacRepository {
  final DioClient dioClient;

  MacRepositoryImpl({required this.dioClient});

  @override
  Future<MacResponseModel> addMacAddress(
      String macAddress, String inverterName, int inverterPower) async {
    try {
      final response = await dioClient.put1(
        ApiEndpoints.addMacAddress,
        queryParams: {
          "macAddress": macAddress,
          "inverter_name": inverterName,
          "inverter_power": inverterPower,
        },
      );
      return MacResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw dioClient.handleDioError(e);
    }
  }
}
// final DioClient dioClient;
//
// MacRepositoryImpl({required this.dioClient});
//
// @override
// Future<MacResponseModel> addMacAddress(
//     String macAddress, String inverterName) async {
//   try {
//     final response = await dioClient.get(
//       ApiEndpoints.addMacAddress,
//       queryParams: {
//         "macAddress": macAddress,
//         "inverter_name": inverterName,
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return MacResponseModel.fromJson(response.data);
//     } else {
//       throw Exception("Failed to add MAC address");
//     }
//   } catch (e) {
//     throw Exception("Error: ${e.toString()}");
//   }
// }
// }
