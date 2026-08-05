import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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
  }
}
