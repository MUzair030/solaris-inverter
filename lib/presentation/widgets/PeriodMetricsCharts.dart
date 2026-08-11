import 'package:flutter/material.dart';

import '../../app/chart_theme.dart';
import '../../data/models/inverter_stats_model.dart';
import '../utils/analytics_chart_data.dart';
import '../viewmodels/energy_analytics_viewmodel.dart';
import 'ZoomableLineChart.dart';

/// Prefers a bucket's real newer-firmware average over its legacy
/// equivalent. Bucket fields are always non-null doubles (never null), so
/// the backend signals "not meaningful for this bucket" (old-firmware-only
/// bucket, or a padded slot) with an explicit `0.0` default rather than
/// null - same convention used everywhere else on [InverterStatsBucket].
/// Treating that `0.0` as "absent" and falling back is the bucket-level
/// equivalent of the nullable `??` prefer-real pattern used on the live
/// dashboard.
double _preferRealAvg(double real, double fallback) =>
    real != 0 ? real : fallback;

/// Renders every metric a period bucket carries, as separate small-multiple
/// charts sharing one x-axis - not one dual-axis chart. Energy (kWh), Power
/// (kW), and Output Current (A) each get their own chart since they're on
/// different scales; PV/Output/Grid Voltage share one chart since all three
/// are Volts and are meaningfully comparable.
///
/// Shared by the dashboard's compact analytics card and the full Analytics
/// screen's "Line" view - one implementation, not duplicated per screen.
///
/// Callers are expected to have already handled the loading/error/empty
/// states for [buckets] (see `EnergyAnalyticsViewModel`) - this widget always
/// assumes at least one bucket is present.
class PeriodMetricsCharts extends StatelessWidget {
  final List<InverterStatsBucket> buckets;
  final AnalyticsPeriod period;

  const PeriodMetricsCharts({
    super.key,
    required this.buckets,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final labels = buildAnalyticsLabels(period, buckets);

    // Newer-firmware-only series (no meaningful old-firmware equivalent) -
    // gated on "at least one bucket in the current view reported it" so an
    // all-old-firmware device/range never renders a flat, misleadingly-real
    // 0.0 line for a meter it simply never reports.
    final hasSolarPower = buckets.any((b) => b.avgSolarPowerKw != 0);
    final hasGridPower = buckets.any((b) => b.avgGridPowerKw != 0);
    final hasGridVoltage = buckets.any((b) => b.avgGridVoltage != 0);
    final hasSolarEnergy = buckets.any((b) => b.solarEnergyDeltaKwh != 0);
    final hasGridEnergy = buckets.any((b) => b.gridEnergyDeltaKwh != 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _chartBlock(
          title: 'Energy',
          unit: 'kWh',
          height: 200,
          child: ZoomableLineChart(
            series: [
              ChartSeries(
                label: 'Energy',
                color: ChartTheme.energy,
                spots: buildAnalyticsSpots(buckets, (b) => b.energyDeltaKwh),
              ),
            ],
            labels: labels,
            unit: 'kWh',
          ),
        ),
        const SizedBox(height: 18),
        _chartBlock(
          title: 'Power',
          unit: 'kW',
          height: 160,
          child: ZoomableLineChart(
            series: [
              if (hasSolarPower)
                ChartSeries(
                  label: 'Solar Power',
                  color: ChartTheme.power,
                  spots: buildAnalyticsSpots(buckets, (b) => b.avgSolarPowerKw),
                ),
              if (hasGridPower)
                ChartSeries(
                  label: 'Grid Power',
                  color: ChartTheme.indigo,
                  spots: buildAnalyticsSpots(buckets, (b) => b.avgGridPowerKw),
                ),
              ChartSeries(
                label: 'Output Power',
                color: ChartTheme.energy,
                spots: buildAnalyticsSpots(
                  buckets,
                  (b) => _preferRealAvg(b.avgOutputPowerKw, b.avgGenPowerKw),
                ),
              ),
            ],
            labels: labels,
            unit: 'kW',
          ),
        ),
        const SizedBox(height: 18),
        _chartBlock(
          title: 'Voltage',
          unit: 'V',
          height: 160,
          child: ZoomableLineChart(
            series: [
              ChartSeries(
                label: 'PV Voltage',
                color: ChartTheme.solarVoltage,
                spots: buildAnalyticsSpots(buckets, (b) => b.avgPvVoltage),
              ),
              ChartSeries(
                label: 'Output Voltage',
                color: ChartTheme.outputVoltage,
                spots: buildAnalyticsSpots(buckets, (b) => b.avgOutputVoltage),
              ),
              if (hasGridVoltage)
                ChartSeries(
                  label: 'Grid Voltage',
                  color: ChartTheme.indigo,
                  spots: buildAnalyticsSpots(buckets, (b) => b.avgGridVoltage),
                ),
            ],
            labels: labels,
            unit: 'V',
          ),
        ),
        const SizedBox(height: 18),
        _chartBlock(
          title: 'Output Current',
          unit: 'A',
          height: 160,
          child: ZoomableLineChart(
            series: [
              ChartSeries(
                label: 'Output Current',
                color: ChartTheme.outputCurrent,
                spots: buildAnalyticsSpots(buckets, (b) => b.avgOutputCurrent),
              ),
            ],
            labels: labels,
            unit: 'A',
          ),
        ),
        // Cumulative solar/grid meters are brand new - only meaningful once
        // at least one bucket actually reported a non-zero delta. Showing a
        // flat 0/0 chart for an old-firmware-only device would look like a
        // confirmed "zero produced/imported" reading rather than "not
        // available", so render a small muted note instead in that case.
        if (hasSolarEnergy || hasGridEnergy) ...[
          const SizedBox(height: 18),
          _chartBlock(
            title: 'Energy Sources',
            unit: 'kWh',
            height: 200,
            child: ZoomableLineChart(
              series: [
                ChartSeries(
                  label: 'Solar Produced',
                  color: ChartTheme.power,
                  spots: buildAnalyticsSpots(
                      buckets, (b) => b.solarEnergyDeltaKwh),
                ),
                ChartSeries(
                  label: 'Grid Imported',
                  color: ChartTheme.indigo,
                  spots: buildAnalyticsSpots(
                      buckets, (b) => b.gridEnergyDeltaKwh),
                ),
              ],
              labels: labels,
              unit: 'kWh',
            ),
          ),
        ] else ...[
          const SizedBox(height: 18),
          const Text(
            'Energy Sources: not available for this device',
            style: TextStyle(fontSize: 11, color: ChartTheme.labelMuted),
          ),
        ],
      ],
    );
  }

  Widget _chartBlock({
    required String title,
    required String unit,
    required double height,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title ($unit)',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: ChartTheme.label,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(height: height, child: child),
      ],
    );
  }
}
