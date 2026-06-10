import '../../data/models/provisioning_response.dart';

abstract class ProvisioningRepository {
  Future<ProvisioningDeleteResponse> deleteDevice(int deviceId);
}
