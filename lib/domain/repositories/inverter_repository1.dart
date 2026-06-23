import '../../data/models/inverter_request_model.dart';
import '../../data/models/inverter_response_model.dart';

abstract class InverterRepository1 {
  Future<List<InverterResponseModel>> fetchInverterData(
      InverterRequestModel request);
}
