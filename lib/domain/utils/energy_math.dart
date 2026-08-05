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
  final delta = today.last.energyConsumed - today.first.energyConsumed;
  return delta < 0 ? 0.0 : delta;
}

/// Buckets today's raw readings by hour and returns 24 per-hour energy
/// deltas (kWh), one per hour of the day containing [now].
///
/// Each hour's value is `max - min` of the cumulative meter reading within
/// that hour (never a sum), clamped to zero. Hours with fewer than two
/// readings (or none at all) report 0.
List<double> hourlyEnergyDeltasToday(
    List<InverterDataModel> data, DateTime now) {
  final today = data.where((d) {
    final t = d.createdAt;
    return t.year == now.year && t.month == now.month && t.day == now.day;
  }).toList();

  final Map<int, double> minByHour = {};
  final Map<int, double> maxByHour = {};

  for (final item in today) {
    final hour = item.createdAt.hour;
    final value = item.energyConsumed;
    if (!minByHour.containsKey(hour) || value < minByHour[hour]!) {
      minByHour[hour] = value;
    }
    if (!maxByHour.containsKey(hour) || value > maxByHour[hour]!) {
      maxByHour[hour] = value;
    }
  }

  return List<double>.generate(24, (hour) {
    final min = minByHour[hour];
    final max = maxByHour[hour];
    if (min == null || max == null) return 0.0;
    final delta = max - min;
    return delta < 0 ? 0.0 : delta;
  });
}
