import '../../data/models/DeviceModel.dart';

abstract class DeviceRepository {
  Future<List<DeviceModel>> fetchDevices();
}
