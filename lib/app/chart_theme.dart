import 'package:flutter/material.dart';

/// Central design tokens for all charts in the app.
///
/// Keeps colors, gradients and label styling consistent across every chart
/// widget so the whole app shares one modern visual language.
class ChartTheme {
  ChartTheme._();

  /// Brand orange — primary accent.
  static const Color brand = Color(0xFFFF6B00);

  /// Metric palette. Order matches series order everywhere:
  /// 0 = Units Consumed (kWh), 1 = Generation Power (kW),
  /// 2 = Solar PV Voltage (V), 3 = Output Voltage (V), 4 = Output Current (A).
  static const Color energy = Color(0xFFFF6B00);
  static const Color power = Color(0xFFFFA726);
  static const Color solarVoltage = Color(0xFF4FC3F7);
  static const Color outputVoltage = Color(0xFF9575CD);
  static const Color outputCurrent = Color(0xFFE57373);

  static const List<Color> metricColors = [
    energy,
    power,
    solarVoltage,
    outputVoltage,
    outputCurrent,
  ];

  /// Display names for the 5 telemetry series (index-aligned with metricColors).
  static const List<String> metricLabels = [
    'Units Consumed',
    'Generation Power',
    'Solar Voltage',
    'Output Voltage',
    'Output Current',
  ];

  /// Units for the 5 telemetry series (index-aligned with metricColors).
  static const List<String> metricUnits = ['kWh', 'kW', 'V', 'V', 'A'];

  /// Extra palette for pie/donut/radar/horizontal-bar charts.
  static const Color cyan = Color(0xFF26C6DA);
  static const Color teal = Color(0xFF26A69A);
  static const Color indigo = Color(0xFF7986CB);
  static const Color lime = Color(0xFF9CCC65);
  static const Color pink = Color(0xFFF06292);
  static const Color deepOrange = Color(0xFFFF7043);

  static const List<Color> categoricalColors = [
    brand,
    cyan,
    indigo,
    lime,
    pink,
    deepOrange,
    teal,
  ];

  /// Axis / grid / text colors for charts on dark cards.
  static const Color label = Color(0xFFB9BDCF);
  static const Color labelMuted = Color(0xFF8F9098);
  static const Color grid = Color(0x1FFFFFFF);
  static const Color gridStrong = Color(0x33FFFFFF);

  /// Y-axis label text style.
  static const TextStyle axisLabelStyle = TextStyle(
    fontSize: 10,
    color: label,
    fontWeight: FontWeight.w500,
  );

  /// X-axis (bottom) label text style.
  static const TextStyle axisBottomLabelStyle = TextStyle(
    fontSize: 10,
    color: label,
  );

  /// Line chart series color getter by index.
  static Color metricColor(int index) => metricColors[index % metricColors.length];

  /// Human friendly compact number: 1234 -> 1.2k, 1_234_567 -> 1.2M.
  static String formatCompact(double value) {
    final abs = value.abs();
    if (abs >= 1e9) return '${(value / 1e9).toStringAsFixed(1)}B';
    if (abs >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
    if (abs >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}k';
    if (abs >= 100) return value.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }

  /// Soft vertical gradient used under line charts / on bar rods.
  static LinearGradient verticalGradient(Color color, {double startOpacity = 0.35, double endOpacity = 0.03}) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withValues(alpha: startOpacity),
        color.withValues(alpha: endOpacity),
      ],
    );
  }
}
