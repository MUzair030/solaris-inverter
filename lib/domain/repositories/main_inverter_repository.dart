import '../../data/models/inverter_data_model.dart';

abstract class MainInverterRepository {
  Future<List<InverterDataModel>?> fetchInverterData(String macAddress);
}
