import '../../data/models/inverter_data_model.dart';
import '../repositories/inverter_repository.dart';

class FetchLatestInverterDataUseCase {
  final InverterRepository repository;

  FetchLatestInverterDataUseCase(this.repository);

  Future<InverterDataModel?> execute(String macAddress) {
    return repository.fetchLatestInverterData(macAddress);
  }
}
