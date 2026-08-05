import '../../data/models/inverter_data_model.dart';
import '../../data/models/inverter_stats_model.dart';

abstract class InverterRepository {
  Future<List<InverterDataModel>> fetchInverterData(String macAddress);
  Future<List<InverterDataModel>> fetchInverterData1(
      String macAddress, String filter);

  /// Fetches aggregated stats buckets from the `/inverter/stats` endpoint.
  Future<List<InverterStatsBucket>> fetchInverterStats(
    String macAddress, {
    required String groupBy,
    String? startDate,
    String? endDate,
  });

  /// Fetches the single latest raw reading from `/inverter/latest`, or null
  /// if the device has no rows yet.
  Future<InverterDataModel?> fetchLatestInverterData(String macAddress);
}
