import '../../data/models/inverter_stats_model.dart';
import '../repositories/inverter_repository.dart';

class FetchInverterStatsUseCase {
  final InverterRepository repository;

  FetchInverterStatsUseCase(this.repository);

  Future<List<InverterStatsBucket>> execute(
    String macAddress, {
    required String groupBy,
    String? startDate,
    String? endDate,
  }) {
    return repository.fetchInverterStats(
      macAddress,
      groupBy: groupBy,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
