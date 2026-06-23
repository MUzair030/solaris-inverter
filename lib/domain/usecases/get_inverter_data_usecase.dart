import 'package:threepol_inverter_flutter/domain/repositories/inverter_repository.dart';

import '../../data/models/geyser_history_request_model.dart';
import '../../data/models/inverter_data_model.dart';

class FetchInverterDataUseCase {
  final InverterRepository repository;

  FetchInverterDataUseCase(this.repository);

  Future<List<InverterDataModel>> execute1(String macAddress) {
    return repository.fetchInverterData(macAddress);
  }

  Future<List<InverterDataModel>> execute2(
      String filter, String macAddress) async {
    return await repository.fetchInverterData1(macAddress, filter);
  }

  Future<List<InverterDataModel>> execute(
      String filter, String macAddress) async {
    List<InverterDataModel> allData =
        await repository.fetchInverterData(macAddress);
    DateTime now = DateTime.now();

    if (filter == "daily") {
      // Group all data by date
      Map<String, List<InverterDataModel>> groupedByDate = {};

      for (var item in allData) {
        final dateStr =
            "${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')}";
        groupedByDate.putIfAbsent(dateStr, () => []).add(item);
      }

      final todayStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      if (groupedByDate.containsKey(todayStr)) {
        return groupedByDate[todayStr]!;
      }

      // 🔁 Return most recent available day if today is missing
      final sortedDates = groupedByDate.keys.toList()
        ..sort((a, b) => b.compareTo(a)); // descending

      for (final dateKey in sortedDates) {
        return groupedByDate[dateKey]!; // First available previous day
      }

      return []; // No data at all
    }

    return allData; // If no filter
  }
}
