import 'package:flutter/material.dart';

import '../../app/chart_theme.dart';

/// Shared dark card wrapper used across the dashboard and the Analytics
/// screen - one implementation so every section's card stays visually
/// consistent, rather than each screen re-declaring its own BoxDecoration.
class SectionCard extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Color accentColor;
  final Widget child;

  const SectionCard({
    super.key,
    this.title,
    this.icon,
    this.accentColor = ChartTheme.brand,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF232739), Color(0xFF1A1C29)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.16)),
        boxShadow: [
          const BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 1),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 15, color: accentColor),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}
