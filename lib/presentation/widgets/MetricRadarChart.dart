import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app/chart_theme.dart';
import 'ChartEmptyState.dart';

/// Single axis of the radar.
class RadarMetric {
  final String label;
  final double value;
  final double max;

  const RadarMetric({
    required this.label,
    required this.value,
    required this.max,
  });

  double get fraction => max <= 0 ? 0 : (value / max).clamp(0.0, 1.0);
}

/// Radar overview comparing the five telemetry dimensions.
///
/// Values are normalized against each metric's own scale so a meaningful
/// "system shape" emerges regardless of differing units.
class MetricRadarChart extends StatelessWidget {
  final List<RadarMetric> metrics;
  final String title;

  const MetricRadarChart({
    super.key,
    required this.metrics,
    this.title = 'System Overview',
  });

  @override
  Widget build(BuildContext context) {
    if (metrics.length < 3) {
      return const ChartEmptyState(
        title: 'Not enough dimensions',
        message: 'Radar needs at least three metrics to render.',
        compact: true,
      );
    }

    final dataSet = RadarDataSet(
      dataEntries: [
        for (final m in metrics) RadarEntry(value: m.fraction),
      ],
      fillColor: ChartTheme.brand.withValues(alpha: 0.22),
      borderColor: ChartTheme.brand,
      borderWidth: 2,
      entryRadius: 3,
    );

    return SizedBox(
      height: 250,
      child: RadarChart(
        RadarChartData(
          dataSets: [dataSet],
          radarShape: RadarShape.polygon,
          radarBackgroundColor: Colors.transparent,
          radarBorderData: const BorderSide(
            color: ChartTheme.gridStrong,
            width: 1,
          ),
          tickCount: 4,
          ticksTextStyle: const TextStyle(
            fontSize: 9,
            color: ChartTheme.labelMuted,
          ),
          tickBorderData: const BorderSide(
            color: ChartTheme.grid,
            width: 1,
          ),
          gridBorderData: const BorderSide(
            color: ChartTheme.grid,
            width: 1,
          ),
          getTitle: (index, angle) => RadarChartTitle(
            text: metrics[index].label,
            angle: angle,
          ),
          titleTextStyle: const TextStyle(
            fontSize: 10,
            color: ChartTheme.label,
            fontWeight: FontWeight.w600,
          ),
          titlePositionPercentageOffset: 0.22,
        ),
      ),
    );
  }
}
