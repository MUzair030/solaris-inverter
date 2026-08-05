import 'package:flutter/material.dart';

import '../../app/App_Colors.dart';

/// Friendly empty / loading placeholder shown inside chart cards when there
/// is no telemetry to render. Prevents blank or crashed charts.
class ChartEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final bool compact;

  const ChartEmptyState({
    super.key,
    this.title = 'No data available',
    this.message = 'Telemetry will appear here once the inverter reports.',
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 28.0 : 44.0;
    final titleStyle = TextStyle(
      fontSize: compact ? 12 : 15,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    );
    final messageStyle = TextStyle(
      fontSize: compact ? 10 : 12,
      color: AppColors.gray2,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insights_outlined,
              size: iconSize,
              color: AppColors.gray2.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: titleStyle),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: messageStyle,
            ),
          ],
        ),
      ),
    );
  }
}
