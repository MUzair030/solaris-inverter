import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:threepol_inverter_flutter/app/App_Colors.dart';
import 'package:threepol_inverter_flutter/app/chart_theme.dart';

import '../../data/models/inverter_data_model.dart';
import 'ChartEmptyState.dart';

/// Modern multi-series line chart used on the Home tab.
///
/// Shows hourly averages of the 5 telemetry metrics with gradient area fills,
/// a rich stacked tooltip and an interactive legend (tap a chip to show/hide
/// that series).
class MultiLineChartWidget extends StatefulWidget {
  final List<InverterDataModel> dataoverall;

  const MultiLineChartWidget({super.key, required this.dataoverall});

  @override
  State<MultiLineChartWidget> createState() => _MultiLineChartWidgetState();
}

class _MultiLineChartWidgetState extends State<MultiLineChartWidget> {
  static final int _metricCount = ChartTheme.metricColors.length;

  final Set<int> _hiddenSeries = {};

  @override
  Widget build(BuildContext context) {
    if (widget.dataoverall.isEmpty) {
      return const SizedBox(
        height: 210,
        child: ChartEmptyState(
          compact: true,
          message: 'Telemetry will appear here once the inverter reports.',
        ),
      );
    }

    final visibleIndices = List.generate(
      _metricCount,
      (m) => m,
      growable: false,
    ).where((m) => !_hiddenSeries.contains(m)).toList();

    if (visibleIndices.isEmpty) {
      return const SizedBox(
        height: 210,
        child: ChartEmptyState(
          compact: true,
          title: 'No series selected',
          message: 'Tap a legend item below to show a metric.',
        ),
      );
    }

    return Column(
      children: [
        SizedBox(height: 210, child: LineChart(_buildLineChart(visibleIndices))),
        const SizedBox(height: 12),
        _buildLegend(),
      ],
    );
  }

  LineChartData _buildLineChart(List<int> visibleIndices) {
    final hourly = _hourlyAverages();
    final hours = <int>[
      for (int h = 0; h < 24; h++)
        if (hourly[h].any((v) => v != null)) h,
    ];
    final firstHour = hours.first;
    final lastHour = hours.last;

    final series = <LineChartBarData>[];
    for (final m in visibleIndices) {
      final spots = <FlSpot>[];
      for (int h = firstHour; h <= lastHour; h++) {
        final v = hourly[h][m];
        spots.add(v == null ? FlSpot.nullSpot : FlSpot(h.toDouble(), v));
      }
      series.add(_buildSeries(m, spots));
    }

    double maxY = 10;
    for (final m in visibleIndices) {
      for (int h = firstHour; h <= lastHour; h++) {
        final v = hourly[h][m];
        if (v != null && v > maxY) maxY = v;
      }
    }
    maxY *= 1.15;

    final span = lastHour - firstHour;
    final interval = _intervalFor(span);
    final dateForHour = _dateForHour();

    return LineChartData(
      minX: firstHour.toDouble(),
      maxX: lastHour.toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: series,
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 34,
            interval: maxY / 4,
            getTitlesWidget: (value, meta) {
              return Text(
                ChartTheme.formatCompact(value),
                style: ChartTheme.axisLabelStyle,
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            interval: interval.toDouble(),
            getTitlesWidget: (value, meta) {
              final hour = value.round();
              if (hour != firstHour &&
                  hour != lastHour &&
                  hour % interval != 0) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _hourLabel(hour),
                  style: ChartTheme.axisBottomLabelStyle,
                ),
              );
            },
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (_) => const FlLine(
          color: ChartTheme.grid,
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          left: BorderSide(color: ChartTheme.gridStrong),
          bottom: BorderSide(color: ChartTheme.gridStrong),
        ),
      ),
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBorderRadius: BorderRadius.circular(10),
          getTooltipColor: (_) => const Color(0xF21A1A26),
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          tooltipMargin: 10,
          getTooltipItems: (touchedSpots) {
            if (touchedSpots.isEmpty) return [];
            final hour = touchedSpots.first.x.round();
            final date = dateForHour[hour];
            final items = <LineTooltipItem>[];
            if (date != null) {
              items.add(
                LineTooltipItem(
                  DateFormat('EEE, MMM d, yyyy').format(date),
                  const TextStyle(
                    fontSize: 10,
                    color: ChartTheme.label,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            for (final spot in touchedSpots) {
              final m = visibleIndices[spot.barIndex];
              items.add(
                LineTooltipItem(
                  '${ChartTheme.metricLabels[m]}    '
                  '${spot.y.toStringAsFixed(1)} ${ChartTheme.metricUnits[m]}',
                  TextStyle(
                    color: ChartTheme.metricColors[m],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            return items;
          },
        ),
      ),
    );
  }

  LineChartBarData _buildSeries(int metricIndex, List<FlSpot> spots) {
    final color = ChartTheme.metricColors[metricIndex];
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      barWidth: 2.2,
      color: color,
      isStrokeJoinRound: true,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: ChartTheme.verticalGradient(color),
      ),
    );
  }

  /// Average of each metric per hour of day. Null cells = no samples that hour.
  List<List<double?>> _hourlyAverages() {
    final sums = List.generate(24, (_) => List<double>.filled(_metricCount, 0));
    final counts = List<int>.filled(24, 0);

    for (final item in widget.dataoverall) {
      final h = item.createdAt.hour;
      sums[h][0] += item.energyConsumed;
      sums[h][1] += item.genPower;
      sums[h][2] += item.pvVoltage;
      sums[h][3] += item.outputVoltage;
      sums[h][4] += item.outputCurrent;
      counts[h]++;
    }

    return List.generate(24, (h) {
      if (counts[h] == 0) return List<double?>.filled(_metricCount, null);
      return [
        for (int m = 0; m < _metricCount; m++) sums[h][m] / counts[h],
      ];
    });
  }

  Map<int, DateTime> _dateForHour() {
    final map = <int, DateTime>{};
    for (final item in widget.dataoverall) {
      map.putIfAbsent(item.createdAt.hour, () => item.createdAt);
    }
    return map;
  }

  int _intervalFor(int span) {
    if (span <= 6) return 1;
    if (span <= 12) return 2;
    if (span <= 20) return 3;
    return 4;
  }

  String _hourLabel(int hour) {
    if (hour == 0) return '12AM';
    if (hour == 12) return '12PM';
    if (hour < 12) return '${hour}AM';
    return '${hour - 12}PM';
  }

  Widget _buildLegend() {
    final latest = _latestItem();
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: List.generate(_metricCount, (m) => _legendChip(m, latest)),
    );
  }

  InverterDataModel? _latestItem() {
    InverterDataModel? latest;
    for (final item in widget.dataoverall) {
      if (latest == null || item.createdAt.isAfter(latest.createdAt)) {
        latest = item;
      }
    }
    return latest;
  }

  double _latestValue(int m, InverterDataModel item) {
    switch (m) {
      case 0:
        return item.energyConsumed;
      case 1:
        return item.genPower;
      case 2:
        return item.pvVoltage;
      case 3:
        return item.outputVoltage;
      case 4:
        return item.outputCurrent;
      default:
        return 0;
    }
  }

  Widget _legendChip(int m, InverterDataModel? latest) {
    final hidden = _hiddenSeries.contains(m);
    final color = ChartTheme.metricColors[m];
    final value = latest == null
        ? ''
        : '${_trim(_latestValue(m, latest))} ${ChartTheme.metricUnits[m]}';

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() {
        hidden ? _hiddenSeries.remove(m) : _hiddenSeries.add(m);
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.cardBorder.withValues(alpha: hidden ? 0.25 : 0.55),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: hidden ? 0.2 : 0.45),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: hidden ? ChartTheme.labelMuted : color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              ChartTheme.metricLabels[m],
              style: TextStyle(
                fontSize: 11,
                color: hidden ? ChartTheme.labelMuted : AppColors.white,
              ),
            ),
            if (value.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: hidden ? 0.5 : 1),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _trim(double v) {
    if (v >= 1000) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}
