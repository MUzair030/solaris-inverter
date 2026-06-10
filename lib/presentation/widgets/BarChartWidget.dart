import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

import '../../app/App_Colors.dart';

class BarChartWidget extends StatelessWidget {
  final List inverterData;

  const BarChartWidget({Key? key, required this.inverterData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(_buildLineChart(inverterData)),
    );
  }

  LineChartData _buildLineChart(List inverterData) {
    List<FlSpot> spots = [];
    Map<int, double> hourData = {};

    // Fill hourData with existing values or 0 if no data
    for (int i = 0; i <= 23; i++) {
      hourData[i] = 0; // Default to zero when no data
    }

    for (var item in inverterData) {
      int hour = item.createdAt.hour;
      hourData[hour] = (hourData[hour] ?? 0) + item.energyConsumed;
    }

    // Convert hourData into FlSpot list
    hourData.forEach((hour, energy) {
      spots.add(FlSpot(hour.toDouble(), energy));
    });

    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          isStepLineChart: false,
          isStrokeJoinRound: true,
          isStrokeCapRound: true,
          barWidth: 1.5,
          color: AppColors.green,
          dotData: const FlDotData(show: false),
          // Hide dots
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppColors.green.withOpacity(0.5),
                AppColors.green.withOpacity(0.2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      titlesData: FlTitlesData(
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 20, // Reduce this value to make the top smaller
            getTitlesWidget: (value, meta) {
              return Text(_formatYAxisLabels(value),
                  style: const TextStyle(fontSize: 12)); // Adjust font size too
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 10,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()} kWh',
                  style: const TextStyle(fontSize: 0));
            },
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 10,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()} kWh',
                  style: const TextStyle(fontSize: 0));
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              return Center(
                child: Text('${value.toInt()}:00',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ),
      ),
      gridData: const FlGridData(show: true),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: AppColors.green,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(1)} kWh',
                const TextStyle(color: AppColors.black, fontSize: 12),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  String _formatYAxisLabels(double value) {
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(1)}B';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}k';
    return value.toStringAsFixed(0);
  }
}
