import '../../data/models/inverter_data_model.dart';
import '../../data/models/inverter_stats_model.dart';

abstract class InverterRepository {
  Future<List<InverterDataModel>> fetchInverterData(String macAddress);
  Future<List<InverterDataModel>> fetchInverterData1(
      String macAddress, String filter);

  /// Server-side aggregated statistics buckets from `/api/inverter/stats`.
  Future<List<InverterStatsModel>> fetchInverterStats(
    String macAddress, {
    required String groupBy,
    String? startDate,
    String? endDate,
  });
}
