import '../../data/models/DeleteResponse.dart';

abstract class DeleteRepository {
  Future<DeleteResponse> deleteDevice(int deviceId);
}
