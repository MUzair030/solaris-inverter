import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/inverter_data_model.dart';

class WeeklyEnergyBarChart extends StatelessWidget {
  final Map<String, double> weeklyData;

  WeeklyEnergyBarChart({required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    final daysOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final labels = daysOrder; // for consistent order
    final maxY = weeklyData.values.isNotEmpty
        ? weeklyData.values.reduce((a, b) => a > b ? a : b) + 1
        : 1.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < daysOrder.length) {
                    return Text(
                      daysOrder[index],
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text("${value.toInt()} kWh",
                      style: const TextStyle(fontSize: 8));
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: daysOrder.asMap().entries.map((entry) {
            int index = entry.key;
            String day = entry.value;
            double energy = weeklyData[day] ?? 0.0;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: energy,
                  color: Colors.blue,
                  width: 16,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
