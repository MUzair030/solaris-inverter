import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../data/models/MacResponseModel.dart';

abstract class MacRepository {
  Future<MacResponseModel> addMacAddress(
      String macAddress, String inverterName, int inverterPower);
}
