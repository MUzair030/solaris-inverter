import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../data/models/inverter_data_model.dart';
import '../../data/models/inverter_stats_model.dart';
import '../viewmodels/energy_analytics_viewmodel.dart';

/// Maps [InverterStatsBucket]s (already zero-padded server-side for
/// continuity) into the `FlSpot`/label pairs the shared [ZoomableLineChart]
/// needs. Kept in one place so the dashboard's compact analytics card and the
/// full Analytics screen render identically from the same
/// [EnergyAnalyticsViewModel] buckets without re-deriving anything.
///
/// `energyDeltaKwh` is used as-is (already a correct max-min delta computed
/// server-side) — never re-summed here.
List<FlSpot> buildAnalyticsSpots(List<InverterStatsBucket> buckets) {
  return [
    for (var i = 0; i < buckets.length; i++)
      FlSpot(i.toDouble(), buckets[i].energyDeltaKwh),
  ];
}

/// Builds one short label per bucket, appropriate for the given [period].
List<String> buildAnalyticsLabels(
  AnalyticsPeriod period,
  List<InverterStatsBucket> buckets,
) {
  switch (period) {
    case AnalyticsPeriod.day:
      return [for (final b in buckets) DateFormat('ha').format(b.bucketStart)];
    case AnalyticsPeriod.week:
      return [for (final b in buckets) DateFormat('EEE').format(b.bucketStart)];
    case AnalyticsPeriod.month:
      return [for (final b in buckets) b.bucketStart.day.toString()];
    case AnalyticsPeriod.year:
      return [for (final b in buckets) DateFormat('MMM').format(b.bucketStart)];
    case AnalyticsPeriod.total:
      return [for (final b in buckets) b.bucket];
    case AnalyticsPeriod.live:
      // Live never renders through this bucket-based helper - see
      // buildLiveSpots/buildLiveLabels below.
      throw StateError('buildAnalyticsLabels() is not valid for AnalyticsPeriod.live');
  }
}

/// Maps [LiveInverterViewModel]'s rolling poll history into the
/// `FlSpot`/label pairs the shared [ZoomableLineChart] needs for the "Live"
/// period. Unlike the bucket-based helpers above, this reflects raw
/// individual readings (already deduped by id in the view model), not a
/// server-aggregated series - each point is one real reading, not a bucket.
List<FlSpot> buildLiveSpots(
  List<InverterDataModel> history,
  double Function(InverterDataModel) valueOf,
) {
  return [
    for (var i = 0; i < history.length; i++)
      FlSpot(i.toDouble(), valueOf(history[i])),
  ];
}

List<String> buildLiveLabels(List<InverterDataModel> history) {
  return [for (final d in history) DateFormat('HH:mm:ss').format(d.createdAt)];
}
