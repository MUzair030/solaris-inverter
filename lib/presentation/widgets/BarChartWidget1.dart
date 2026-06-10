import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget1 extends StatelessWidget {
  final Map<String, double> energyData;
  final List<String> labels;

  const BarChartWidget1({
    super.key,
    required this.energyData,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < labels.length) {
                  return Text(labels[value.toInt()]);
                }
                return const Text('');
              },
              interval: 1,
            ),
          ),
        ),
        barGroups: List.generate(labels.length, (index) {
          final key = energyData.keys.elementAt(index);
          final energy = energyData[key]!;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: energy,
                color: Colors.blue,
                width: 18,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }

  double _getMaxY() {
    final max = energyData.values
        .fold<double>(0.0, (prev, element) => element > prev ? element : prev);
    return max < 10 ? 10 : max + 5;
  }
}
