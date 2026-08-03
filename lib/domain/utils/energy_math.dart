import '../../data/models/inverter_data_model.dart';

/// Computes how much energy (kWh) was produced for the day containing [now].
///
/// The device's `energy` field is a cumulative meter reading (kWh since
/// install), so "energy produced today" is the delta between the latest and
/// earliest reading of that day — never the sum of readings, which would
/// massively over-count.
double energyTodayKwh(List<InverterDataModel> data, DateTime now) {
  if (data.isEmpty) return 0.0;
  final today = data.where((d) {
    final t = d.createdAt;
    return t.year == now.year && t.month == now.month && t.day == now.day;
  }).toList();
  if (today.length < 2) return 0.0;
  final delta =
      today.last.energyConsumed - today.first.energyConsumed;
  return delta < 0 ? 0.0 : delta;
}
