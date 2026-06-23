import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../domain/repositories/provisioning_repository.dart';
import '../models/provisioning_response.dart';

class ProvisioningRepositoryImpl implements ProvisioningRepository {
  final DioClient dioClient;

  ProvisioningRepositoryImpl(this.dioClient);

  @override
  Future<ProvisioningDeleteResponse> deleteDevice(int deviceId) async {
    final response = await dioClient
        .delete(ApiEndpoints.provisioningDeleteDevice, queryParameters: {
      'deviceId': deviceId,
    }, headers: {
      'Accept': 'text/plain'
    });
    return ProvisioningDeleteResponse.fromPlainText(response.data.toString());
  }
}
