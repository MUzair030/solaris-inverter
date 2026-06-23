import '../../data/models/DeleteResponse.dart';
import '../repositories/DeleteRepository.dart';

class DeleteDeviceUseCase {
  final DeleteRepository repository;

  DeleteDeviceUseCase(this.repository);

  Future<DeleteResponse> call(int deviceId) {
    return repository.deleteDevice(deviceId);
  }
}
