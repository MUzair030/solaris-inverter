import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app/chart_theme.dart';

/// One line/area series on a [ZoomableLineChart]. Every series on a given
/// chart instance must share the same unit/scale — this widget renders a
/// single y-axis, never a dual axis, so plotting two differently-scaled
/// metrics (e.g. Volts and Amps) on the same [ZoomableLineChart] would be
/// misleading. Use separate chart instances for metrics with different units.
class ChartSeries {
  final String label;
  final Color color;
  final List<FlSpot> spots;

  const ChartSeries({
    required this.label,
    required this.color,
    required this.spots,
  });
}

/// Interactive line chart with pinch-to-zoom, double-tap reset, touch tooltip
/// and smooth animation between data sets. Supports one or more [series]
/// sharing a single x-axis (labels) and y-axis (unit) — a legend is shown
/// automatically whenever there's more than one series.
///
/// Zoom operates on the x axis around the current view center (kept simple and
/// reliable). The tooltip shows the exact value of every series under the
/// finger, colored to match its legend entry.
class ZoomableLineChart extends StatefulWidget {
  final List<ChartSeries> series;
  final List<String> labels;
  final String unit;
  final double Function(double y)? format;

  const ZoomableLineChart({
    super.key,
    required this.series,
    required this.labels,
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

  int get _pointCount => widget.series.isEmpty
      ? 0
      : widget.series.map((s) => s.spots.length).reduce(math.max);

  double get _fullStart => -0.5;
  double get _fullEnd => math.max(1, _pointCount - 1) + 0.5;

  /// Picks a "nice" axis step (1/2/5 x a power of 10) for [targetSteps]
  /// divisions of [rawMax], plus how many decimals are needed to show
  /// distinct labels at that step (avoids e.g. 0, 0.72, 1.44 all rounding to
  /// "0, 1, 1" when maxY is small, as happens often with hourly kWh deltas).
  (double, int) _niceAxisStep(double rawMax, int targetSteps) {
    if (rawMax <= 0) return (1.0, 0);
    final rawStep = rawMax / targetSteps;
    final magnitude =
        math.pow(10, (math.log(rawStep) / math.ln10).floor()).toDouble();
    final residual = rawStep / magnitude;
    double niceResidual;
    if (residual >= 5) {
      niceResidual = 10;
    } else if (residual >= 2) {
      niceResidual = 5;
    } else if (residual >= 1) {
      niceResidual = 2;
    } else {
      niceResidual = 1;
    }
    final step = niceResidual * magnitude;
    final decimals = step >= 1 ? 0 : (step >= 0.1 ? 1 : 2);
    return (step, decimals);
  }

  @override
  void initState() {
    super.initState();
    _viewStart = _fullStart;
    _viewEnd = _fullEnd;
  }

  double? _lastYOf(List<ChartSeries> series) =>
      series.isEmpty || series.first.spots.isEmpty
          ? null
          : series.first.spots.last.y;

  @override
  void didUpdateWidget(ZoomableLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.series.length != widget.series.length ||
        _pointCount !=
            (oldWidget.series.isEmpty
                ? 0
                : oldWidget.series.map((s) => s.spots.length).reduce(math.max)) ||
        _lastYOf(oldWidget.series) != _lastYOf(widget.series)) {
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
    final hasData = widget.series.any((s) => s.spots.isNotEmpty);
    if (!hasData) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: ChartTheme.labelMuted, fontSize: 12),
        ),
      );
    }

    final maxY = widget.series
        .expand((s) => s.spots)
        .map((s) => s.y)
        .fold(0.0, math.max);
    final rawMax = maxY <= 0 ? 1.0 : maxY * 1.15;
    final (axisStep, axisDecimals) = _niceAxisStep(rawMax, 4);
    final niceMax = axisStep * 4;

    final labelStep = math.max(1, (_pointCount / 5).ceil());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.series.length > 1) _Legend(series: widget.series),
        if (widget.series.length > 1) const SizedBox(height: 8),
        Expanded(
          child: GestureDetector(
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
                        final s = widget.series[spot.barIndex];
                        final v = widget.format?.call(spot.y) ?? spot.y;
                        final prefix =
                            widget.series.length > 1 ? '${s.label}: ' : '';
                        return LineTooltipItem(
                          '$prefix${v.toStringAsFixed(2)} ${widget.unit}',
                          TextStyle(
                            fontSize: 11,
                            color: widget.series.length > 1
                                ? s.color
                                : Colors.white,
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
                  horizontalInterval: axisStep,
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
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: axisStep,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(axisDecimals),
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
                  for (final s in widget.series)
                    LineChartBarData(
                      spots: s.spots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      preventCurveOverShooting: true,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      color: s.color,
                      gradient: LinearGradient(
                        colors: [s.color, s.color.withValues(alpha: 0.6)],
                      ),
                      belowBarData: BarAreaData(
                        // A filled area under more than one overlapping series
                        // would obscure the series beneath it - only fill when
                        // this is the sole series on the chart.
                        show: widget.series.length == 1,
                        gradient: ChartTheme.verticalGradient(
                          s.color,
                          startOpacity: 0.30,
                          endOpacity: 0.02,
                        ),
                      ),
                      dotData: FlDotData(
                        show: s.spots.length <= 24,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 3,
                          color: s.color.withValues(alpha: 0.9),
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
          ),
        ),
      ],
    );
  }
}

/// Small colored-dot + label row, one entry per series. Shown whenever a
/// chart has more than one series, per the identity-never-color-alone rule -
/// each entry also carries its text label, not just a colored swatch.
class _Legend extends StatelessWidget {
  final List<ChartSeries> series;

  const _Legend({required this.series});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      children: [
        for (final s in series)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                s.label,
                style: const TextStyle(fontSize: 11, color: ChartTheme.label),
              ),
            ],
          ),
      ],
    );
  }
}
