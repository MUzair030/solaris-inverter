import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app/chart_theme.dart';
import 'ChartEmptyState.dart';

/// One plotted point on the scatter chart.
class ScatterPoint {
  final double x;
  final double y;
  final String label;

  const ScatterPoint({
    required this.x,
    required this.y,
    required this.label,
  });
}

/// Correlation scatter (e.g. output voltage vs output current).
///
/// Dots are colored on a brand gradient by their relative y value and reveal a
/// tooltip on tap.
class ScatterCorrelationChart extends StatefulWidget {
  final List<ScatterPoint> points;
  final String xLabel;
  final String yLabel;

  const ScatterCorrelationChart({
    super.key,
    required this.points,
    this.xLabel = 'Output Voltage (V)',
    this.yLabel = 'Output Current (A)',
  });

  @override
  State<ScatterCorrelationChart> createState() =>
      _ScatterCorrelationChartState();
}

class _ScatterCorrelationChartState extends State<ScatterCorrelationChart> {
  int _touchedIndex = -1;

  double get _maxX => widget.points.fold(
        0.0,
        (m, p) => p.x > m ? p.x : m,
      );
  double get _maxY => widget.points.fold(
        0.0,
        (m, p) => p.y > m ? p.y : m,
      );

  int _indexOf(ScatterSpot spot) {
    for (var i = 0; i < widget.points.length; i++) {
      final p = widget.points[i];
      if (p.x == spot.x && p.y == spot.y) return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.length < 2) {
      return const ChartEmptyState(
        title: 'Not enough readings',
        message: 'Scatter needs at least two readings to render.',
        compact: true,
      );
    }

    final maxX = _maxX <= 0 ? 1.0 : _maxX;
    final maxY = _maxY <= 0 ? 1.0 : _maxY;

    final spots = List.generate(widget.points.length, (i) {
      final p = widget.points[i];
      final t = (p.y / maxY).clamp(0.0, 1.0);
      final color = Color.lerp(ChartTheme.cyan, ChartTheme.brand, t)!;
      return ScatterSpot(
        p.x,
        p.y,
        dotPainter: FlDotCirclePainter(
          radius: i == _touchedIndex ? 8 : 5,
          color: color.withValues(alpha: 0.9),
          strokeWidth: i == _touchedIndex ? 2 : 1,
          strokeColor: i == _touchedIndex
              ? Colors.white
              : color.withValues(alpha: 0.5),
        ),
      );
    });

    return SizedBox(
      height: 230,
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: spots,
              minX: 0,
              maxX: maxX * 1.1,
              minY: 0,
              maxY: maxY * 1.15,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: maxY / 4,
                verticalInterval: maxX / 4,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: ChartTheme.grid,
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (_) => const FlLine(
                  color: ChartTheme.grid,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
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
                    reservedSize: 34,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox.shrink();
                      return Text(
                        value.toStringAsFixed(0),
                        style: ChartTheme.axisLabelStyle,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          value.toStringAsFixed(0),
                          style: ChartTheme.axisBottomLabelStyle,
                        ),
                      );
                    },
                  ),
                ),
              ),
              scatterTouchData: ScatterTouchData(
                touchTooltipData: ScatterTouchTooltipData(
                  tooltipBorderRadius: BorderRadius.circular(8),
                  getTooltipColor: (_) => const Color(0xFF232638),
                  getTooltipItems: (touchedSpot) {
                    final index = _indexOf(touchedSpot);
                    if (index < 0) return null;
                    return ScatterTooltipItem(
                      widget.points[index].label,
                      textStyle: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
                touchCallback: (event, response) {
                  if (event is! FlTapUpEvent) return;
                  final touched = response?.touchedSpot;
                  setState(() {
                    _touchedIndex = touched?.spotIndex ?? -1;
                  });
                },
              ),
            ),
          ),
        );
  }
}
