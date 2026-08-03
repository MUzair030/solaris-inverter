import 'package:flutter/material.dart';

import '../../app/chart_theme.dart';

/// One live metric definition shown in the dashboard grid.
class LiveMetric {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const LiveMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });
}

/// A single animated live-value card.
class LiveMetricCard extends StatelessWidget {
  final LiveMetric metric;

  const LiveMetricCard({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: metric.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: metric.color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(metric.icon, size: 16, color: metric.color),
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                metric.unit,
                style: TextStyle(
                  fontSize: 10,
                  color: metric.color,
                  fontWeight: FontWeight.w700,
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
        final itemWidth =
            (constraints.maxWidth - 10 * (columns - 1)) / columns;
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
