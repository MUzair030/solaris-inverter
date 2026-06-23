import 'package:threepol_inverter_flutter/domain/entities/geyser_history_data_entity.dart';

import '../../data/models/geyser_history_request_model.dart';
import '../../data/models/geyser_history_response_model.dart';

abstract class GeyserHistoryRepository {
  Future<List<GeyserHistoryResponseModel>> fetchGeyserData(
      GeyserHistoryRequestModel request);
}
