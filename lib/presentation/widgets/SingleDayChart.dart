import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app/App_Colors.dart';
import '../../data/models/inverter_data_model.dart';
import 'LegendItem.dart';

// class SingleDayChart extends StatelessWidget {
//   final List<InverterDataModel> dataList;
//
//   const SingleDayChart({Key? key, required this.dataList}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//
//     // Step 1: Filter today's data
//     List<InverterDataModel> filteredData = dataList
//         .where((e) =>
//             e.createdAt.year == now.year &&
//             e.createdAt.month == now.month &&
//             e.createdAt.day == now.day)
//         .toList();
//
//     // Step 2: Fallback to most recent previous date
//     if (filteredData.isEmpty && dataList.isNotEmpty) {
//       final sorted = [...dataList]
//         ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
//       final latest = sorted.first.createdAt;
//       filteredData = dataList
//           .where((e) =>
//               e.createdAt.year == latest.year &&
//               e.createdAt.month == latest.month &&
//               e.createdAt.day == latest.day)
//           .toList();
//     }
//
//     if (filteredData.isEmpty) {
//       return const Center(child: Text("No data available"));
//     }
//
//     // Step 3: Group into 5-hour blocks
//     final Map<int, List<InverterDataModel>> groupedData = {};
//     for (var data in filteredData) {
//       final block = (data.createdAt.hour ~/ 5) * 5; // 0-4, 5-9, etc.
//       groupedData.putIfAbsent(block, () => []).add(data);
//     }
//
//     // Step 4: Create bar groups
//     List<BarChartGroupData> barGroups = [];
//     for (var entry in groupedData.entries) {
//       final blockHour = entry.key;
//       final values = entry.value;
//
//       double avgOrZero(List<double> list) =>
//           list.isEmpty ? 0 : list.reduce((a, b) => a + b) / list.length;
//
//       final avgEnergy = avgOrZero(values.map((e) => e.energyConsumed).toList());
//       final avgGen = avgOrZero(values.map((e) => e.genPower).toList());
//       final avgPV = avgOrZero(values.map((e) => e.pvVoltage).toList());
//       final avgOutVolt = avgOrZero(values.map((e) => e.outputVoltage).toList());
//       final avgCurrent = avgOrZero(values.map((e) => e.outputCurrent).toList());
//
//       barGroups.add(
//         BarChartGroupData(
//           x: blockHour,
//           barRods: [
//             BarChartRodData(toY: avgEnergy, color: Colors.orange, width: 6),
//             BarChartRodData(toY: avgGen, color: const Color(0xFF2277BB), width: 6),
//             BarChartRodData(toY: avgPV, color: Colors.blue, width: 6),
//             BarChartRodData(toY: avgOutVolt, color: Colors.purple, width: 6),
//             BarChartRodData(toY: avgCurrent, color: Colors.red, width: 6),
//           ],
//           barsSpace: 2,
//         ),
//       );
//     }
//
//     final maxY = _getMaxY(groupedData);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 16),
//         buildLegend(),
//         const SizedBox(height: 16),
//         SizedBox(
//           height: 350,
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: SizedBox(
//               width: barGroups.length * 80.0, // allow space per group
//               child: BarChart(
//                 BarChartData(
//                   maxY: maxY,
//                   barGroups: barGroups,
//                   groupsSpace: 30, // space between each group
//                   titlesData: FlTitlesData(
//                     leftTitles: AxisTitles(
//                       sideTitles:
//                           SideTitles(showTitles: true, reservedSize: 40),
//                     ),
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 30,
//                         getTitlesWidget: (value, _) {
//                           final start = value.toInt();
//                           final end = start + 4;
//                           return Text(
//                             "$start–$end h",
//                             style: const TextStyle(fontSize: 10),
//                           );
//                         },
//                       ),
//                     ),
//                     topTitles: AxisTitles(),
//                     rightTitles: AxisTitles(),
//                   ),
//                   barTouchData: BarTouchData(enabled: true),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   double _getMaxY(Map<int, List<InverterDataModel>> groupedMap) {
//     double maxY = 0;
//     for (var list in groupedMap.values) {
//       for (var v in list) {
//         maxY = [
//           maxY,
//           v.energyConsumed,
//           v.genPower,
//           v.pvVoltage,
//           v.outputVoltage,
//           v.outputCurrent
//         ].reduce((a, b) => a > b ? a : b);
//       }
//     }
//     return maxY == 0 ? 10 : maxY * 1.2;
//   }
//
//   Widget buildLegend() {
//     return Wrap(
//       spacing: 10,
//       runSpacing: 8,
//       children: const [
//         LegendItem(color: Colors.orange, label: 'Energy Consumed'),
//         LegendItem(color: const Color(0xFF2277BB), label: 'Gen Power'),
//         LegendItem(color: Colors.blue, label: 'PV Voltage'),
//         LegendItem(color: Colors.purple, label: 'Output Voltage'),
//         LegendItem(color: Colors.red, label: 'Output Current'),
//       ],
//     );
//   }
// }

class SingleDayChart extends StatelessWidget {
  final List<InverterDataModel> dataList;

  const SingleDayChart({Key? key, required this.dataList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Step 1: Group data by date (yyyy-MM-dd)
    final Map<String, List<InverterDataModel>> groupedByDate = {};

    for (var data in dataList) {
      final dateKey =
          "${data.createdAt.year}-${data.createdAt.month.toString().padLeft(2, '0')}-${data.createdAt.day.toString().padLeft(2, '0')}";
      groupedByDate.putIfAbsent(dateKey, () => []).add(data);
    }

    // Step 2: Sort the dates in descending order
    final sortedDates = groupedByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // latest first

    // Step 3: Pick the latest date with data (today or fallback)
    String? selectedDate;
    final today = DateTime.now();
    final todayKey =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    if (groupedByDate.containsKey(todayKey)) {
      selectedDate = todayKey;
    } else if (sortedDates.isNotEmpty) {
      selectedDate = sortedDates.first;
    }

    final selectedData =
        selectedDate != null ? groupedByDate[selectedDate]! : [];

    // Step 4: Group data by hour and average values
    final Map<int, List<InverterDataModel>> hourlyMap = {};
    for (var data in selectedData) {
      final hour = data.createdAt.hour;
      hourlyMap.putIfAbsent(hour, () => []).add(data);
    }

    List<BarChartGroupData> barGroups = [];

    // for (var entry in hourlyMap.entries) {
    for (var entry in hourlyMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key))) {
      final hour = entry.key;
      final values = entry.value;

      double avgEnergy =
          values.map((e) => e.energyConsumed).reduce((a, b) => a + b) /
              values.length;
      double avgGen =
          values.map((e) => e.genPower).reduce((a, b) => a + b) / values.length;
      double avgPV = values.map((e) => e.pvVoltage).reduce((a, b) => a + b) /
          values.length;
      double avgOutVolt =
          values.map((e) => e.outputVoltage).reduce((a, b) => a + b) /
              values.length;
      double avgCurrent =
          values.map((e) => e.outputCurrent).reduce((a, b) => a + b) /
              values.length;

      barGroups.add(
        BarChartGroupData(
          x: hour,
          barRods: [
            BarChartRodData(toY: avgEnergy, color: Colors.orange, width: 8),
            BarChartRodData(toY: avgGen, color: const Color(0xFF2277BB), width: 8),
            BarChartRodData(toY: avgPV, color: Colors.blue, width: 8),
            BarChartRodData(toY: avgOutVolt, color: Colors.purple, width: 8),
            BarChartRodData(toY: avgCurrent, color: Colors.red, width: 8),
          ],
          barsSpace: 2,
        ),
      );
    }

    final maxY = _getMaxY(hourlyMap);

    return barGroups.isNotEmpty
        ? BarChart(
            BarChartData(
              maxY: maxY,
              barGroups: barGroups,
              groupsSpace: 20,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) => Text("${value.toInt()}:00",
                        style: const TextStyle(fontSize: 10)),
                    reservedSize: 30,
                  ),
                ),
                topTitles: AxisTitles(),
                rightTitles: AxisTitles(),
              ),
              barTouchData: BarTouchData(enabled: true),
              borderData: FlBorderData(show: false),
            ),
          )
        : const Center(child: Text("No data available for any day"));
  }

  double _getMaxY(Map<int, List<InverterDataModel>> hourlyMap) {
    double maxY = 0;
    for (var values in hourlyMap.values) {
      for (var v in values) {
        maxY = [
          maxY,
          v.energyConsumed,
          v.genPower,
          v.pvVoltage,
          v.outputVoltage,
          v.outputCurrent
        ].reduce((a, b) => a > b ? a : b);
      }
    }
    return maxY * 1.2;
  }
}
