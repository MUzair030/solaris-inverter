import '../../data/models/inverter_data_model.dart';
import '../repositories/main_inverter_repository.dart';

class FetchMainInverterDataUseCase {
  final MainInverterRepository repository;

  FetchMainInverterDataUseCase(this.repository);

  Future<List<InverterDataModel>?> execute(String macAddress) {
    return repository.fetchInverterData(macAddress);
  }

  Future<List<InverterDataModel>?> call(String macAddress) {
    return repository.fetchInverterData(macAddress);
  }
}
