import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/chart_theme.dart';
import '../../data/models/inverter_stats_model.dart';
import '../utils/analytics_chart_data.dart';
import '../viewmodels/SelectedDeviceProvider.dart';
import '../viewmodels/energy_analytics_viewmodel.dart';
import '../widgets/AnalyticsPeriodSelector.dart';
import '../widgets/ChartEmptyState.dart';
import '../widgets/EnergyDonutChart.dart';
import '../widgets/HeaderWidget.dart';
import '../widgets/MetricBarChart.dart';
import '../widgets/MetricRadarChart.dart';
import '../widgets/PowerGaugeWidget.dart';
import '../widgets/ScatterCorrelationChart.dart';
import '../widgets/WelcomeWidget.dart';
import '../widgets/ZoomableLineChart.dart';

enum _VizType { line, bar, gauge, donut, radar, scatter }

/// Analytics screen. Reads the SAME [EnergyAnalyticsViewModel] instance the
/// dashboard's compact analytics card uses (shared higher up in
/// `Mainbottomnavigationview`), so switching period/date here is reflected on
/// the dashboard too and vice versa — and neither screen re-fetches when the
/// other already has the data loaded.
///
/// The chart-type row (Line/Bar/Gauge/Donut/Radar/Scatter) all render from
/// the one already-loaded bucket list; picking a different chart type never
/// triggers a new network request.
class Statisticsscreen extends StatefulWidget {
  const Statisticsscreen({super.key});

  @override
  State<Statisticsscreen> createState() => _StatisticsscreenState();
}

class _StatisticsscreenState extends State<Statisticsscreen> {
  _VizType _viz = _VizType.line;

  static const List<(_VizType, IconData, String)> _vizOptions = [
    (_VizType.line, Icons.show_chart, 'Line'),
    (_VizType.bar, Icons.bar_chart_outlined, 'Bar'),
    (_VizType.gauge, Icons.speed_outlined, 'Gauge'),
    (_VizType.donut, Icons.donut_large_outlined, 'Donut'),
    (_VizType.radar, Icons.radar, 'Radar'),
    (_VizType.scatter, Icons.scatter_plot_outlined, 'Scatter'),
  ];

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<EnergyAnalyticsViewModel>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/bg.png", fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.1)),
          Padding(
            padding:
                const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 70),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 35),
                  const HeaderWidget(),
                  const SizedBox(height: 20),
                  const WelcomeWidget(),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2130),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                            spreadRadius: 2),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Analytics',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const AnalyticsPeriodSelector(),
                        const SizedBox(height: 14),
                        _vizSwitcher(),
                        const SizedBox(height: 14),
                        _buildBody(analytics),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vizSwitcher() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _vizOptions.map((option) {
          final type = option.$1;
          final icon = option.$2;
          final label = option.$3;
          final isActive = _viz == type;
          return GestureDetector(
            onTap: () => setState(() => _viz = type),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? ChartTheme.brand : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? ChartTheme.brand : ChartTheme.gridStrong,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon,
                      size: 14,
                      color: isActive ? Colors.white : ChartTheme.label),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : ChartTheme.label,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(EnergyAnalyticsViewModel analytics) {
    if (analytics.isLoading && analytics.buckets.isEmpty) {
      return const SizedBox(
        height: 240,
        child: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: ChartTheme.brand),
        ),
      );
    }
    if (analytics.errorMessage != null && analytics.buckets.isEmpty) {
      return const SizedBox(
        height: 240,
        child: ChartEmptyState(
          title: 'Could not load analytics',
          message: 'Check your connection and try again.',
          compact: true,
        ),
      );
    }
    final buckets = analytics.buckets;
    if (buckets.isEmpty) {
      return const SizedBox(
        height: 240,
        child: ChartEmptyState(
          title: 'No data for this range',
          message: 'The inverter has not reported in this period.',
          compact: true,
        ),
      );
    }

    final total = buckets.fold<double>(0.0, (s, b) => s + b.energyDeltaKwh);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total ${total.toStringAsFixed(2)} kWh · ${buckets.length} '
          'period${buckets.length == 1 ? '' : 's'}',
          style: const TextStyle(fontSize: 12, color: ChartTheme.label),
        ),
        const SizedBox(height: 10),
        _buildViz(analytics),
      ],
    );
  }

  Widget _buildViz(EnergyAnalyticsViewModel analytics) {
    switch (_viz) {
      case _VizType.line:
        return _buildLine(analytics);
      case _VizType.bar:
        return _buildBars(analytics.buckets);
      case _VizType.gauge:
        return _buildGauge(analytics.buckets);
      case _VizType.donut:
        return _buildDonut(analytics);
      case _VizType.radar:
        return _buildRadar(analytics.buckets);
      case _VizType.scatter:
        return _buildScatter(analytics.buckets);
    }
  }

  Widget _buildLine(EnergyAnalyticsViewModel analytics) {
    return SizedBox(
      height: 240,
      child: ZoomableLineChart(
        spots: buildAnalyticsSpots(analytics.buckets),
        labels: buildAnalyticsLabels(analytics.period, analytics.buckets),
        color: ChartTheme.brand,
        unit: 'kWh',
      ),
    );
  }

  Widget _buildBars(List<InverterStatsBucket> buckets) {
    final last = buckets.last;
    return MetricBarChart(
      items: [
        MetricBarItem(
          label: 'Units Produced',
          value: last.energyDeltaKwh,
          unit: 'kWh',
          color: ChartTheme.energy,
        ),
        MetricBarItem(
          label: 'Generation Power',
          value: last.avgGenPowerKw,
          unit: 'kW',
          color: ChartTheme.power,
        ),
        MetricBarItem(
          label: 'Solar Voltage',
          value: last.avgPvVoltage,
          unit: 'V',
          color: ChartTheme.solarVoltage,
        ),
        MetricBarItem(
          label: 'Output Voltage',
          value: last.avgOutputVoltage,
          unit: 'V',
          color: ChartTheme.outputVoltage,
        ),
        MetricBarItem(
          label: 'Output Current',
          value: last.avgOutputCurrent,
          unit: 'A',
          color: ChartTheme.outputCurrent,
        ),
      ],
    );
  }

  Widget _buildGauge(List<InverterStatsBucket> buckets) {
    final last = buckets.last;
    double maxKw = 0;
    final devicePower = context.read<SelectedDeviceProvider>().power;
    if (devicePower != null && devicePower > 0) {
      maxKw = devicePower / 1000.0;
    }
    if (maxKw <= 0) {
      maxKw = buckets.fold(
              0.0, (m, b) => b.avgGenPowerKw > m ? b.avgGenPowerKw : m) *
          1.1;
    }
    if (maxKw <= 0) maxKw = 1;
    return PowerGaugeWidget(
      value: last.avgGenPowerKw,
      max: maxKw,
      subtitle: last.bucket,
    );
  }

  Widget _buildDonut(EnergyAnalyticsViewModel analytics) {
    final buckets = analytics.buckets;
    final labels = buildAnalyticsLabels(analytics.period, buckets);
    final indexed =
        List.generate(buckets.length, (i) => (buckets[i], labels[i]));
    final sorted = [...indexed]
      ..sort((a, b) => b.$1.energyDeltaKwh.compareTo(a.$1.energyDeltaKwh));
    final top = sorted.take(6).toList();
    final rest =
        sorted.skip(6).fold<double>(0.0, (s, e) => s + e.$1.energyDeltaKwh);
    final segments = <DonutSegment>[
      for (var i = 0; i < top.length; i++)
        DonutSegment(
          label: top[i].$2,
          value: top[i].$1.energyDeltaKwh,
          color: ChartTheme
              .categoricalColors[i % ChartTheme.categoricalColors.length],
        ),
      if (rest > 0)
        DonutSegment(label: 'Other', value: rest, color: ChartTheme.gridStrong),
    ];
    return EnergyDonutChart(segments: segments);
  }

  Widget _buildRadar(List<InverterStatsBucket> buckets) {
    final last = buckets.last;
    double maxOf(double Function(InverterStatsBucket) f) =>
        buckets.fold(0.0, (m, b) => f(b) > m ? f(b) : m);
    final maxEnergy = maxOf((b) => b.energyDeltaKwh);
    final maxGen = maxOf((b) => b.avgGenPowerKw);
    final maxPv = maxOf((b) => b.avgPvVoltage);
    final maxOutV = maxOf((b) => b.avgOutputVoltage);
    final maxOutA = maxOf((b) => b.avgOutputCurrent);
    return MetricRadarChart(
      metrics: [
        RadarMetric(
          label: 'Energy',
          value: last.energyDeltaKwh,
          max: maxEnergy <= 0 ? 1 : maxEnergy,
        ),
        RadarMetric(
          label: 'Power',
          value: last.avgGenPowerKw,
          max: maxGen <= 0 ? 1 : maxGen,
        ),
        RadarMetric(
          label: 'PV V',
          value: last.avgPvVoltage,
          max: maxPv <= 0 ? 1 : maxPv,
        ),
        RadarMetric(
          label: 'Out V',
          value: last.avgOutputVoltage,
          max: maxOutV <= 0 ? 1 : maxOutV,
        ),
        RadarMetric(
          label: 'Out A',
          value: last.avgOutputCurrent,
          max: maxOutA <= 0 ? 1 : maxOutA,
        ),
      ],
    );
  }

  Widget _buildScatter(List<InverterStatsBucket> buckets) {
    final points = buckets
        .map((b) => ScatterPoint(
              x: b.avgOutputVoltage,
              y: b.avgOutputCurrent,
              label: '${b.bucket} · '
                  '${b.avgOutputVoltage.toStringAsFixed(1)} V · '
                  '${b.avgOutputCurrent.toStringAsFixed(1)} A',
            ))
        .toList();
    return ScatterCorrelationChart(points: points);
  }
}
