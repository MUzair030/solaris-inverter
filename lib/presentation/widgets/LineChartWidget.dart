import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:threepol_inverter_flutter/app/chart_theme.dart';

import '../../data/models/inverter_data_model.dart';
import 'ChartEmptyState.dart';

/// Modern hourly energy-consumption line chart used in the Statistics daily view.
class LineChartWidget extends StatelessWidget {
  final List<InverterDataModel> inverterData;

  const LineChartWidget({super.key, required this.inverterData});

  @override
  Widget build(BuildContext context) {
    if (inverterData.isEmpty) {
      return const ChartEmptyState(compact: true);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: LineChart(_buildLineChart()),
    );
  }

  LineChartData _buildLineChart() {
    final hourly = _hourlyEnergy();
    final hours = <int>[
      for (int h = 0; h < 24; h++)
        if (hourly[h] != null) h,
    ];
    final firstHour = hours.first;
    final lastHour = hours.last;

    final spots = <FlSpot>[];
    for (int h = firstHour; h <= lastHour; h++) {
      final v = hourly[h];
      spots.add(v == null ? FlSpot.nullSpot : FlSpot(h.toDouble(), v));
    }

    final maxY = (hourly.whereType<double>().fold<double>(0, (a, b) => a > b ? a : b) * 1.2).clamp(10.0, double.infinity);
    final span = lastHour - firstHour;
    final interval = _intervalFor(span);
    final dateForHour = _dateForHour();

    return LineChartData(
      minX: firstHour.toDouble(),
      maxX: lastHour.toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 2.2,
          color: ChartTheme.brand,
          isStrokeJoinRound: true,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: ChartTheme.verticalGradient(ChartTheme.brand),
          ),
        ),
      ],
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
            items.add(
              LineTooltipItem(
                'Energy    ${touchedSpots.first.y.toStringAsFixed(1)} kWh',
                const TextStyle(
                  color: ChartTheme.brand,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
            return items;
          },
        ),
      ),
    );
  }

  List<double?> _hourlyEnergy() {
    // `energyConsumed` is a cumulative meter, so the energy produced in each
    // hour is the delta between the highest and lowest readings of that hour —
    // never an average of the meter.
    final mins = List<double?>.filled(24, null);
    final maxs = List<double?>.filled(24, null);
    for (final item in inverterData) {
      final h = item.createdAt.hour;
      final v = item.energyConsumed;
      if (mins[h] == null || v < mins[h]!) mins[h] = v;
      if (maxs[h] == null || v > maxs[h]!) maxs[h] = v;
    }
    return [
      for (int h = 0; h < 24; h++)
        (mins[h] == null || maxs[h] == null)
            ? null
            : ((maxs[h]! - mins[h]!) < 0 ? 0 : maxs[h]! - mins[h]!),
    ];
  }

  Map<int, DateTime> _dateForHour() {
    final map = <int, DateTime>{};
    for (final item in inverterData) {
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
}
