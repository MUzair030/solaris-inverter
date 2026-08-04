import 'package:flutter/material.dart';

import '../../app/chart_theme.dart';

/// "Today's Solar Production" summary card.
///
/// Shows today's system output (the daily meter delta) as the measured value.
class TodayProductionCard extends StatelessWidget {
  final double todayEnergyKwh;
  final String updatedAt;

  const TodayProductionCard({
    super.key,
    required this.todayEnergyKwh,
    this.updatedAt = '--',
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
        ],
      ),
    );
  }
}
