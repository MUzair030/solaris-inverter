import '../../data/models/provisioning_response.dart';
import '../repositories/provisioning_repository.dart';

class ProvisioningDeleteDeviceUseCase {
  final ProvisioningRepository repository;

  ProvisioningDeleteDeviceUseCase(this.repository);

  Future<ProvisioningDeleteResponse> call(int deviceId) {
    return repository.deleteDevice(deviceId);
  }
}
