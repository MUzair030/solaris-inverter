import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/inverter_data_model.dart';
import '../viewmodels/inverter_viewmodel1.dart';

class WeeklyBarChart extends StatelessWidget {
  final String macAddress;

  const WeeklyBarChart({Key? key, required this.macAddress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<InverterViewModel1>(
      builder: (context, viewModel, child) {
        // ✅ Define start & end of current week (Mon - Sun)
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));

        // ✅ Filter inverter data for current week
        final filteredData = viewModel.inverterData.where((item) {
          final created = DateTime(
              item.createdAt.year, item.createdAt.month, item.createdAt.day);
          return created
                  .isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
              created.isBefore(endOfWeek.add(const Duration(days: 1)));
        }).toList();

        // ✅ Prepare bar chart data (includes 0.0 for missing days)
        final Map<String, double> weeklyEnergy =
            _prepareWeeklyEnergy(filteredData, startOfWeek);

        // ✅ Check if all days are 0 (then show fallback message)
        final hasAnyData = weeklyEnergy.values.any((value) => value > 0);
        if (!hasAnyData) {
          return const Center(child: Text("No data available"));
        }

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceBetween,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final labels = weeklyEnergy.keys.toList();
                      return Text(
                        labels[value.toInt()],
                        style: const TextStyle(fontSize: 10),
                      );
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
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups:
                  weeklyEnergy.entries.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final label = entry.value.key;
                final value = entry.value.value;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      color: const Color(0xFF2277BB),
                      width: 16,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  /// ✅ Prepare weekly energy data with fallback 0.0 for missing days
  Map<String, double> _prepareWeeklyEnergy(
      List<InverterDataModel> data, DateTime startOfWeek) {
    final Map<String, double> dailyEnergy = {};

    // ✅ Initialize 7 days with 0.0
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final label = DateFormat('EEE').format(date); // e.g. Mon, Tue
      dailyEnergy[label] = 0.0;
    }

    // ✅ Fill in real data if exists
    for (final item in data) {
      final date = DateTime(
          item.createdAt.year, item.createdAt.month, item.createdAt.day);
      final label = DateFormat('EEE').format(date);
      if (dailyEnergy.containsKey(label)) {
        dailyEnergy[label] = (dailyEnergy[label] ?? 0.0) + item.energyConsumed;
      }
    }

    return dailyEnergy;
  }
}

// class WeeklyBarChart extends StatelessWidget {
//   final List data; // List<InverterDataModel>
//   final DateTime startOfWeek;
//
//   const WeeklyBarChart(
//       {super.key, required this.data, required this.startOfWeek});
//
//   @override
//   Widget build(BuildContext context) {
//     // ✅ 1. Initialize energy values for all 7 days as 0
//     Map<String, double> dailyEnergy = {};
//     List<String> weekLabels = [];
//
//     for (int i = 0; i < 7; i++) {
//       final date = startOfWeek.add(Duration(days: i));
//       final label = DateFormat('EEE').format(date); // Mon, Tue, etc.
//       weekLabels.add(label);
//       dailyEnergy[label] = 0.0;
//     }
//
//     // ✅ 2. Fill energy values from real data
//     for (var item in data) {
//       final label = DateFormat('EEE').format(item.createdAt);
//       if (dailyEnergy.containsKey(label)) {
//         dailyEnergy[label] = (dailyEnergy[label] ?? 0.0) + item.energyConsumed;
//       }
//     }
//
//     // ✅ 3. Build bar chart groups
//     final barGroups = weekLabels.asMap().entries.map((entry) {
//       final index = entry.key;
//       final label = entry.value;
//       final value = dailyEnergy[label] ?? 0.0;
//
//       return BarChartGroupData(
//         x: index,
//         barRods: [
//           BarChartRodData(
//             toY: value,
//             color: Colors.blue,
//             width: 16,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ],
//       );
//     }).toList();
//
//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         maxY: dailyEnergy.values.reduce((a, b) => a > b ? a : b) + 10,
//         barGroups: barGroups,
//         titlesData: FlTitlesData(
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               interval: 20,
//               reservedSize: 40,
//               getTitlesWidget: (value, meta) {
//                 return Text('${value.toInt()} kWh',
//                     style: const TextStyle(fontSize: 10));
//               },
//             ),
//           ),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 return Text(weekLabels[value.toInt()],
//                     style: const TextStyle(fontSize: 10));
//               },
//             ),
//           ),
//         ),
//         borderData: FlBorderData(show: false),
//         gridData: FlGridData(show: true),
//       ),
//     );
//   }
// }
