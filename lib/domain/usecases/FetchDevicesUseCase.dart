import '../../data/models/DeviceModel.dart';
import '../repositories/DeviceRepository.dart';

class FetchDevicesUseCase {
  final DeviceRepository repository;

  FetchDevicesUseCase(this.repository);

  Future<List<DeviceModel>> execute() async {
    return await repository.fetchDevices();
  }
}
