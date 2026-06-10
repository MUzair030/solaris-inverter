import '../../data/models/inverter_request_model.dart';
import '../../data/models/inverter_response_model.dart';
import '../repositories/inverter_repository1.dart';

class FetchInverterDataUseCase1 {
  final InverterRepository1 repository;

  FetchInverterDataUseCase1(this.repository);

  Future<List<InverterResponseModel>> call(InverterRequestModel request) {
    return repository.fetchInverterData(request);
  }
}
