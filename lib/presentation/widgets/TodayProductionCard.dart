import 'package:flutter/material.dart';

import '../../app/chart_theme.dart';

/// "Today's Solar Production" summary card.
///
/// Shows today's system output (the daily meter delta) as the measured value,
/// plus a small hourly sparkline underneath so the day's shape is visible at
/// a glance (no legend/axis — this is a compact glanceable indicator, not a
/// full chart).
class TodayProductionCard extends StatelessWidget {
  final double todayEnergyKwh;
  final String updatedAt;

  /// Per-hour energy deltas (kWh) for today, 24 entries (hour 0..23).
  /// Pass an empty list to hide the sparkline row.
  final List<double> hourlySparkline;

  const TodayProductionCard({
    super.key,
    required this.todayEnergyKwh,
    this.updatedAt = '--',
    this.hourlySparkline = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1606), Color(0xFF1E2130)],
        ),
        border: Border.all(color: ChartTheme.brand.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: ChartTheme.brand.withValues(alpha: 0.18),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TODAY'S SOLAR PRODUCTION",
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              color: ChartTheme.labelMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  todayEnergyKwh.toStringAsFixed(2),
                  key: ValueKey<String>(todayEnergyKwh.toStringAsFixed(2)),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'kWh',
                  style: TextStyle(
                    fontSize: 14,
                    color: ChartTheme.brand,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'System Output Today',
                      style: TextStyle(
                        fontSize: 11,
                        color: ChartTheme.labelMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Updated $updatedAt',
                      style: const TextStyle(
                        fontSize: 10,
                        color: ChartTheme.label,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hourlySparkline.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 32,
              child: _HourlySparkline(values: hourlySparkline),
            ),
          ],
        ],
      ),
    );
  }
}

/// Minimal bar sparkline showing today's hourly energy shape. Deliberately
/// has no axis labels/legend — it is a glance indicator, not a full chart.
class _HourlySparkline extends StatelessWidget {
  final List<double> values;

  const _HourlySparkline({required this.values});

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<double>(0, (m, v) => v > m ? v : m);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final value in values)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: FractionallySizedBox(
                    alignment: Alignment.bottomCenter,
                    heightFactor:
                        value <= 0 ? 0.04 : (value / safeMax).clamp(0.06, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: value > 0
                            ? ChartTheme.brand.withValues(alpha: 0.85)
                            : ChartTheme.gridStrong,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
