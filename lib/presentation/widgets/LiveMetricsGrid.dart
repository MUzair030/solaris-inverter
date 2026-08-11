import 'package:flutter/material.dart';

import '../../app/chart_theme.dart';

/// One live metric definition shown in the dashboard grid.
///
/// [disabled] renders a dimmed placeholder card (e.g. Grid Input, which this
/// hardware doesn't report yet) - never a fabricated value. When true,
/// [value]/[unit] should just be `'--'`/`'No data'`, not an invented number.
class LiveMetric {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final bool disabled;

  const LiveMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.disabled = false,
  });
}

/// A single animated live-value card.
class LiveMetricCard extends StatelessWidget {
  final LiveMetric metric;

  const LiveMetricCard({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    final disabled = metric.disabled;
    final color = disabled ? ChartTheme.labelMuted : metric.color;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: disabled ? 0.04 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: disabled ? 0.15 : 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(metric.icon, size: 16, color: color.withValues(alpha: disabled ? 0.6 : 1)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  metric.label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: ChartTheme.labelMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    metric.value,
                    key: ValueKey<String>(metric.value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: disabled ? ChartTheme.labelMuted : Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  metric.unit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Responsive grid of live metric cards.
class LiveMetricsGrid extends StatelessWidget {
  final List<LiveMetric> metrics;

  const LiveMetricsGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 3 : 2;
        final itemWidth = (constraints.maxWidth - 10 * (columns - 1)) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: itemWidth,
                child: LiveMetricCard(metric: metric),
              ),
          ],
        );
      },
    );
  }
}
