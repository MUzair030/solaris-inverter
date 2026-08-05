import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app/chart_theme.dart';
import 'ChartEmptyState.dart';

/// A single wedge of the donut chart.
class DonutSegment {
  final String label;
  final double value;
  final Color color;

  const DonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });
}

/// Modern interactive donut (energy / distribution) chart.
///
/// Tapping a wedge pops it outward and shows its share in the center.
class EnergyDonutChart extends StatefulWidget {
  final List<DonutSegment> segments;
  final String centerTitle;
  final String unit;

  const EnergyDonutChart({
    super.key,
    required this.segments,
    this.centerTitle = 'Total',
    this.unit = 'kWh',
  });

  @override
  State<EnergyDonutChart> createState() => _EnergyDonutChartState();
}

class _EnergyDonutChartState extends State<EnergyDonutChart> {
  int _touchedIndex = -1;

  double get _total => widget.segments
      .fold(0.0, (sum, s) => sum + (s.value.isFinite ? s.value : 0));

  @override
  Widget build(BuildContext context) {
    if (widget.segments.isEmpty || _total <= 0) {
      return const ChartEmptyState(
        title: 'No energy data',
        message:
            'Energy distribution will appear here once the inverter reports.',
        compact: true,
      );
    }

    final touched = _touchedIndex >= 0 && _touchedIndex < widget.segments.length
        ? widget.segments[_touchedIndex]
        : null;

    final sections = List.generate(widget.segments.length, (i) {
      final segment = widget.segments[i];
      final isTouched = i == _touchedIndex;
      final value = segment.value.isFinite ? segment.value : 0.0;
      return PieChartSectionData(
        value: value,
        color: segment.color,
        radius: isTouched ? 62 : 48,
        showTitle: false,
        borderSide: const BorderSide(
          width: 4,
          color: Color(0xFF1E2130),
        ),
        cornerRadius: 6,
      );
    });

    return Column(
      children: [
        SizedBox(
          height: 210,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 64,
                  startDegreeOffset: -90,
                  sectionsSpace: 3,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (event is! FlTapUpEvent) return;
                      setState(() {
                        _touchedIndex =
                            response?.touchedSection?.touchedSectionIndex ?? -1;
                      });
                    },
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (touched ?? widget.segments.first).label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      color: ChartTheme.labelMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ChartTheme.formatCompact(
                      touched?.value ?? _total,
                    ),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.unit,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ChartTheme.label,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          children: widget.segments.asMap().entries.map((entry) {
            final i = entry.key;
            final segment = entry.value;
            final share = _total > 0 ? (segment.value / _total) * 100 : 0.0;
            return GestureDetector(
              onTap: () => setState(() => _touchedIndex = i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: i == _touchedIndex
                      ? segment.color.withValues(alpha: 0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: segment.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${segment.label} ${share.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 11,
                        color: ChartTheme.label,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
