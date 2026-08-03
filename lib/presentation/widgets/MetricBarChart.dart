import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app/chart_theme.dart';
import 'ChartEmptyState.dart';

/// One horizontal rod.
class MetricBarItem {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const MetricBarItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });
}

/// Horizontal bar chart for comparing latest telemetry metrics.
///
/// Uses fl_chart's rotated bars (rotationQuarterTurns) so rods run
/// horizontally and each value is labeled at its tip.
class MetricBarChart extends StatelessWidget {
  final List<MetricBarItem> items;

  const MetricBarChart({super.key, required this.items});

  double get _maxValue {
    var m = 0.0;
    for (final item in items) {
      if (item.value > m) m = item.value;
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const ChartEmptyState(
        title: 'No metric data',
        message: 'Metrics will appear here once the inverter reports.',
        compact: true,
      );
    }

    final max = _maxValue <= 0 ? 1.0 : _maxValue;
    final maxLabel = ChartTheme.formatCompact(max);

    return SizedBox(
      height: items.length * 44 + 30,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            rotationQuarterTurns: 1,
            minY: 0,
            maxY: max * 1.15,
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              drawHorizontalLine: false,
              horizontalInterval: max / 4,
              verticalInterval: max / 4,
              getDrawingVerticalLine: (_) => const FlLine(
                color: ChartTheme.grid,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 92,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= items.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          items[index].label,
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: ChartTheme.label,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                axisNameWidget: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '0     ${maxLabel}',
                    style: ChartTheme.axisBottomLabelStyle,
                  ),
                ),
                sideTitles: const SideTitles(showTitles: false),
              ),
            ),
            barGroups: [
              for (var i = 0; i < items.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: items[i].value,
                      width: 18,
                      borderRadius: BorderRadius.circular(9),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          items[i].color.withValues(alpha: 0.55),
                          items[i].color,
                        ],
                      ),
                      label: BarChartRodLabel(
                        show: true,
                        text: ChartTheme.formatCompact(items[i].value),
                        style: const TextStyle(
                          fontSize: 9,
                          color: ChartTheme.label,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
