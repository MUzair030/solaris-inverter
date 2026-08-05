import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app/chart_theme.dart';

/// Interactive line chart with pinch-to-zoom, double-tap reset, touch tooltip
/// and smooth animation between data sets.
///
/// Zoom operates on the x axis around the current view center (kept simple and
/// reliable). The tooltip shows the exact value under the finger.
class ZoomableLineChart extends StatefulWidget {
  final List<FlSpot> spots;
  final List<String> labels;
  final Color color;
  final String unit;
  final double Function(double y)? format;

  const ZoomableLineChart({
    super.key,
    required this.spots,
    required this.labels,
    required this.color,
    this.unit = 'kWh',
    this.format,
  });

  @override
  State<ZoomableLineChart> createState() => _ZoomableLineChartState();
}

class _ZoomableLineChartState extends State<ZoomableLineChart> {
  late double _viewStart;
  late double _viewEnd;
  double _baseStart = 0;
  double _baseEnd = 0;

  double get _fullStart => -0.5;
  double get _fullEnd => math.max(1, widget.spots.length - 1) + 0.5;

  @override
  void initState() {
    super.initState();
    _viewStart = _fullStart;
    _viewEnd = _fullEnd;
  }

  @override
  void didUpdateWidget(ZoomableLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spots.length != widget.spots.length ||
        oldWidget.spots.isEmpty ||
        (widget.spots.isNotEmpty &&
            oldWidget.spots.last.y != widget.spots.last.y)) {
      _viewStart = _fullStart;
      _viewEnd = _fullEnd;
    }
  }

  void _resetView() {
    setState(() {
      _viewStart = _fullStart;
      _viewEnd = _fullEnd;
    });
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseStart = _viewStart;
    _baseEnd = _viewEnd;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final fullSpan = _fullEnd - _fullStart;
    final span = (_baseEnd - _baseStart);
    final newSpan = (span / details.scale).clamp(1.0, fullSpan);
    final center = (_baseStart + _baseEnd) / 2;
    var start = center - newSpan / 2;
    var end = center + newSpan / 2;
    if (start < _fullStart) {
      end += _fullStart - start;
      start = _fullStart;
    }
    if (end > _fullEnd) {
      start -= end - _fullEnd;
      end = _fullEnd;
    }
    if (start < _fullStart) start = _fullStart;
    setState(() {
      _viewStart = start;
      _viewEnd = end;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.spots.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: ChartTheme.labelMuted, fontSize: 12),
        ),
      );
    }

    final maxY = widget.spots.map((s) => s.y).reduce(math.max);
    final niceMax = maxY <= 0 ? 1.0 : maxY * 1.15;

    final labelStep = math.max(1, (widget.spots.length / 5).ceil());

    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onDoubleTap: _resetView,
      child: LineChart(
        LineChartData(
          minX: _viewStart,
          maxX: _viewEnd,
          minY: 0,
          maxY: niceMax,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xF21A1A26),
              tooltipBorderRadius: BorderRadius.circular(10),
              tooltipMargin: 10,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final v = widget.format?.call(spot.y) ?? spot.y;
                  return LineTooltipItem(
                    '${v.toStringAsFixed(2)} ${widget.unit}',
                    const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: niceMax / 4,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: ChartTheme.grid,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
            getDrawingVerticalLine: (_) => const FlLine(
              color: ChartTheme.grid,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: niceMax / 4,
                getTitlesWidget: (value, meta) {
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
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (value != index.toDouble() ||
                      index < 0 ||
                      index >= widget.labels.length ||
                      index % labelStep != 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      widget.labels[index],
                      style: ChartTheme.axisBottomLabelStyle,
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: widget.spots,
              isCurved: true,
              curveSmoothness: 0.3,
              preventCurveOverShooting: true,
              barWidth: 3,
              isStrokeCapRound: true,
              color: widget.color,
              gradient: LinearGradient(
                colors: [
                  widget.color,
                  widget.color.withValues(alpha: 0.6),
                ],
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: ChartTheme.verticalGradient(
                  widget.color,
                  startOpacity: 0.30,
                  endOpacity: 0.02,
                ),
              ),
              dotData: FlDotData(
                show: widget.spots.length <= 24,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 3,
                  color: widget.color.withValues(alpha: 0.9),
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}
