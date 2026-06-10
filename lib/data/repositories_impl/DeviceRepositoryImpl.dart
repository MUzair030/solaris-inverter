import 'package:threepol_inverter_flutter/core/network/api_endpoints.dart';

import '../../../core/network/dio_client.dart';
import '../../domain/repositories/DeviceRepository.dart';
import '../models/DeviceModel.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DioClient dioClient;

  DeviceRepositoryImpl(this.dioClient);

  @override
  Future<List<DeviceModel>> fetchDevices() async {
    try {
      final response = await dioClient.get(ApiEndpoints.devicesList);
      final List<dynamic> data = response.data;

      return data.map((json) => DeviceModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Failed to fetch devices: $e");
    }
  }
}
