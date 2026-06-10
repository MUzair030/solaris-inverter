import '../../data/models/inverter_data_model.dart';

abstract class InverterRepository {
  Future<List<InverterDataModel>> fetchInverterData(String macAddress);
  Future<List<InverterDataModel>> fetchInverterData1(
      String macAddress, String filter);
}
