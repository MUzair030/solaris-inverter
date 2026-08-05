import 'package:flutter/material.dart';

import '../../app/chart_theme.dart';
import '../../data/models/inverter_stats_model.dart';
import '../utils/analytics_chart_data.dart';
import '../viewmodels/energy_analytics_viewmodel.dart';
import 'ZoomableLineChart.dart';

/// Renders every metric a period bucket carries, as separate small-multiple
/// charts sharing one x-axis - not one dual-axis chart. Energy (kWh),
/// Generation Power (kW), and Output Current (A) each get their own chart
/// since they're on different scales; PV Voltage and Output Voltage share one
/// chart since both are Volts and are meaningfully comparable.
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
          title: 'Generation Power',
          unit: 'kW',
          height: 160,
          child: ZoomableLineChart(
            series: [
              ChartSeries(
                label: 'Generation Power',
                color: ChartTheme.power,
                spots: buildAnalyticsSpots(buckets, (b) => b.avgGenPowerKw),
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
