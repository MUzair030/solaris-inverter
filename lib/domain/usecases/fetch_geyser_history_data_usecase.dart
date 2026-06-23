import '../../data/models/geyser_history_request_model.dart';
import '../../data/models/geyser_history_response_model.dart';
import '../entities/geyser_history_data_entity.dart';
import '../repositories/geyser_history_repository.dart';

class FetchGeyserHistoryDataUseCase {
  final GeyserHistoryRepository repository;

  FetchGeyserHistoryDataUseCase(this.repository);

  Future<List<GeyserHistoryResponseModel>> execute(
      GeyserHistoryRequestModel request) async {
    return await repository.fetchGeyserData(request);
  }
}
