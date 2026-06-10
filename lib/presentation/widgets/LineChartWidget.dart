import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/App_Colors.dart';
import '../../data/models/inverter_data_model.dart';

class LineChartWidget extends StatelessWidget {
  final List inverterData;

  const LineChartWidget({Key? key, required this.inverterData})
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

    // Group data by hour
    final Map<int, List<InverterDataModel>> hourlyData = {};
    for (var item in inverterData) {
      final hour = item.createdAt.hour;
      hourlyData.putIfAbsent(hour, () => []).add(item);
    }

    // Sort hours
    final hours = hourlyData.keys.toList()..sort();
    final latestHour = hours.isNotEmpty ? hours.last : 0;

    double interval;
    if (latestHour <= 6) {
      interval = 1;
    } else if (latestHour <= 12) {
      interval = 2;
    } else if (latestHour <= 18) {
      interval = 3;
    } else {
      interval = 4; // max spacing
    }

    // Fill hourData with existing values or 0 if no data
    for (int i = 1; i <= 24; i++) {
      hourData[i] = 0;
    }

    for (var item in inverterData) {
      int hour = item.createdAt.hour;
      hourData[hour] = item.energyConsumed;
      // hourData[hour] = (hourData[hour] ?? 0) + item.energyConsumed;
    }

    // Convert hourData into FlSpot list
    hourData.forEach((hour, energy) {
      spots.add(FlSpot(hour.toDouble(), energy));
    });

    // Common formatting function for Y-axis labels
    String _formatYAxisLabels(double value) {
      if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(1)}B';
      if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
      if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}k';
      return value.toStringAsFixed(0);
    }

    // Mon to Sun
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          isStepLineChart: false,
          isStrokeJoinRound: true,
          isStrokeCapRound: true,
          barWidth: 1.5,
          // color: AppColors.green,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      ],
      titlesData: FlTitlesData(
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 20,
            getTitlesWidget: (value, meta) {
              return Text(_formatYAxisLabels(value),
                  style: const TextStyle(fontSize: 9, color: AppColors.black));
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 25,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()} kWh',
                  style: const TextStyle(fontSize: 8, color: AppColors.black));
            },
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 0,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()} kWh',
                  style: const TextStyle(fontSize: 0, color: AppColors.black));
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: interval,
            getTitlesWidget: (value, meta) {
              // final hour = value.toInt();
              // final formatted = '${hour.toString().padLeft(1, '0')}';
              // // return Text(formatted,
              // //     style: const TextStyle(fontSize: 9, color: AppColors.black));
              //
              // return Transform.rotate(
              //   angle: 35 * 3.1415926535 / 180,
              //   child: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Text(formatted,
              //         style:
              //             const TextStyle(fontSize: 9, color: AppColors.black)),
              //   ),
              // );

              int hour = value.toInt();

              // Only show labels for hours divisible by 3 or the last hour (24)
              // For pattern like 1, 4, 7, 10, 13, 16, 19, 22
              // Or you can use: (hour - 1) % 3 == 0
              if ((hour - 1) % 3 == 0 || hour == 24) {
                return Transform.rotate(
                  angle: 35 * 3.1415926535 / 180,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      hour.toString(),
                      style:
                          const TextStyle(fontSize: 9, color: AppColors.black),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
              // int intValue = value.toInt();
              // if (intValue < 1 || intValue > 24) return const SizedBox.shrink();
              // if ((intValue - 1) % 3 != 0 && intValue != 24) {
              //   return const SizedBox.shrink();
              // }
              // return Padding(
              //   padding: const EdgeInsets.only(top: 6.0),
              //   child: Text(
              //     value.toInt().toString(),
              //     style: const TextStyle(fontSize: 9, color: AppColors.black),
              //   ),
              // );
            },
          ),
        ),
      ),
      minX: 1,
      maxX: 24,
      minY: 0,
      gridData: const FlGridData(show: true),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          // tooltipBgColor: AppColors.green,
          tooltipRoundedRadius: 8,
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
}
