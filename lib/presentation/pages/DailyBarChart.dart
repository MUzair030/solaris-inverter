import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/inverter_viewmodel1.dart';

import '../../app/App_Colors.dart';
import '../../data/models/BarChartDataPoint.dart';
import '../../data/models/inverter_data_model.dart';
import '../widgets/BarChartWidget1.dart';

class DailyBarChart extends StatelessWidget {
  final List<InverterDataModel> inverterData;

  DailyBarChart({required this.inverterData});

  // Get list of all days in current week (Monday to Sunday)
  List<DateTime> _getCurrentWeekDates() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday; // Monday=1
    DateTime startOfWeek = now.subtract(Duration(days: currentWeekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  // Convert DateTime to label "yyyy-MM-dd"
  String _getDateLabel(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Prepare data: fill missing days with zero
  List<BarChartDataPoint> _prepareWeeklyData() {
    final weekDates = _getCurrentWeekDates();

    // Map existing data by date label
    Map<String, InverterDataModel> dataMap = {
      for (var item in inverterData) _getDateLabel(item.createdAt): item
    };

    // Build list with all days of the week, filling missing with 0
    List<BarChartDataPoint> weeklyData = [];
    for (var date in weekDates) {
      String label = _getDateLabel(date);
      double value = 0;
      if (dataMap.containsKey(label)) {
        value = dataMap[label]!.energyConsumed;
      }
      weeklyData.add(BarChartDataPoint(label: label, value: value));
    }
    return weeklyData;
  }

  @override
  Widget build(BuildContext context) {
    final weeklyData = _prepareWeeklyData();

    // Generate bar groups
    List<BarChartGroupData> barGroups = weeklyData.asMap().entries.map((entry) {
      int index = entry.key;
      final dataPoint = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: dataPoint.value,
            color: dataPoint.value > 0 ? AppColors.green : Colors.grey[300],
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    // Labels for the bottom axis
    List<String> labels = weeklyData.map((d) {
      DateTime date = DateTime.parse(d.label);
      return DateFormat('E').format(date); // Mon, Tue, etc.
    }).toList();

    // Highlight today
    String todayLabel = _getDateLabel(DateTime.now());
    int todayIndex = weeklyData.indexWhere((d) => d.label == todayLabel);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          maxY: _getMaxY(weeklyData),
          barGroups: barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < labels.length) {
                    return Transform.rotate(
                      angle: 35 * 3.1415926535 / 180,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          labels[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: index == todayIndex
                                ? Colors.orange
                                : Colors.white,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: _getYInterval(weeklyData),
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()} kWh',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  );
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.green,
              tooltipPadding: const EdgeInsets.all(4),
              tooltipMargin: 0,
              fitInsideVertically: true,
              fitInsideHorizontally: true,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                // conditionally show tooltip or not
                if (rod.toY == 0) {
                  return null; // no tooltip
                }
                return BarTooltipItem(
                  '${rod.toY.toStringAsFixed(2)} kWh',
                  const TextStyle(color: Colors.white, fontSize: 10),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double _getMaxY(List<BarChartDataPoint> data) {
    double maxY = data.fold(0.0, (a, b) => a > b.value ? a : b.value);
    return maxY == 0 ? 10 : maxY * 1.2; // add some headroom
  }

  double _getYInterval(List<BarChartDataPoint> data) {
    double maxY = _getMaxY(data);
    double interval = maxY / 5;
    if (interval <= 0) interval = 1;
    return interval;
  }
}

// class DailyBarChart extends StatelessWidget {
//   final List<InverterDataModel> inverterData;
//
//   DailyBarChart({required this.inverterData});
//
//   // Get list of dates for current week (Monday to Sunday)
//   List<DateTime> _getCurrentWeekDates() {
//     DateTime now = DateTime.now();
//     int currentWeekday = now.weekday; // Monday=1
//     DateTime startOfWeek = now.subtract(Duration(days: currentWeekday - 1));
//     return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
//   }
//
//   // Convert DateTime to label "yyyy-MM-dd"
//   String _getDateLabel(DateTime date) {
//     return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
//   }
//
//   // Prepare data: fill missing days with zero
//   List<BarChartDataPoint> _prepareDailyData() {
//     final weekDates = _getCurrentWeekDates();
//
//     // Map existing data by date label
//     Map<String, InverterDataModel> dataMap = {
//       for (var item in inverterData) _getDateLabel(item.createdAt): item
//     };
//
//     // Build list with all days of the week
//     List<BarChartDataPoint> dailyData = [];
//     for (var date in weekDates) {
//       String label = _getDateLabel(date);
//       double value = 0.0;
//       if (dataMap.containsKey(label)) {
//         value = dataMap[label]!.energyConsumed;
//       }
//       dailyData.add(BarChartDataPoint(label: label, value: value));
//     }
//     return dailyData;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final dailyData = _prepareDailyData();
//
//     // Generate bar groups
//     List<BarChartGroupData> barGroups = dailyData.asMap().entries.map((entry) {
//       int index = entry.key;
//       final dataPoint = entry.value;
//       return BarChartGroupData(
//         x: index,
//         barRods: [
//           BarChartRodData(
//             toY: dataPoint.value,
//             color: Colors.blue,
//             width: 20,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ],
//       );
//     }).toList();
//
//     // Labels for the bottom axis
//     List<String> labels = dailyData.map((d) {
//       DateTime date = DateTime.parse(d.label);
//       return DateFormat('E').format(date); // Mon, Tue, etc.
//     }).toList();
//
//     // Get the date of today for highlighting
//     String todayLabel = _getDateLabel(DateTime.now());
//
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: BarChart(
//         BarChartData(
//           maxY: _getMaxY(dailyData),
//           barGroups: barGroups,
//           titlesData: FlTitlesData(
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 getTitlesWidget: (value, meta) {
//                   int index = value.toInt();
//                   if (index >= 0 && index < labels.length) {
//                     String label = labels[index];
//                     bool isToday = dailyData[index].label == todayLabel;
//                     return Transform.rotate(
//                       angle: 35 * 3.1415926535 / 180,
//                       child: Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Text(
//                           label,
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: isToday ? Colors.orange : Colors.white,
//                           ),
//                         ),
//                       ),
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),
//             ),
//             leftTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 interval: _getYInterval(dailyData),
//                 getTitlesWidget: (value, meta) {
//                   return Text(
//                     '${value.toInt()} kWh',
//                     style: const TextStyle(fontSize: 10, color: Colors.white),
//                   );
//                 },
//               ),
//             ),
//             topTitles: AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//             rightTitles: AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//           ),
//           gridData: const FlGridData(show: true),
//           borderData: FlBorderData(show: false),
//           barTouchData: BarTouchData(
//             enabled: true,
//             touchTooltipData: BarTouchTooltipData(
//               tooltipBgColor: Colors.orange,
//               getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                 return BarTooltipItem(
//                   '${rod.toY.toStringAsFixed(2)} kWh',
//                   const TextStyle(color: Colors.white),
//                 );
//               },
//             ),
//             touchCallback: (FlTouchEvent event, response) {
//               // Optional: handle tap events
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   double _getMaxY(List<BarChartDataPoint> data) {
//     double maxY = data.fold(0.0, (a, b) => a > b.value ? a : b.value);
//     return maxY == 0 ? 10 : maxY * 1.2; // Headroom
//   }
//
//   double _getYInterval(List<BarChartDataPoint> data) {
//     double maxY = _getMaxY(data);
//     double interval = maxY / 5;
//     if (interval <= 0) interval = 1;
//     return interval;
//   }
// }

class BarChartDataPoint {
  final String label; // date label "yyyy-MM-dd"
  final double value;

  BarChartDataPoint({required this.label, required this.value});
}

// @override
// Widget build(BuildContext context) {
//   final labels = generateWeekLabels(widget.startOfWeek);
//   final dataWithDefaults = _injectZeroBarsForMissingDays(widget.inverterData);
//
//   return Padding(
//     padding: const EdgeInsets.all(8.0),
//     child: BarChart(_buildWeeklyBarChart(dataWithDefaults)),
//   );
// }

/// Ensures all days Mon–Sun have at least one entry (or default with 0.0)
// List<InverterDataModel> _injectZeroBarsForMissingDays(
//     List<InverterDataModel> data) {
//   final DateTime now = DateTime.now();
//   final int currentWeekday = now.weekday;
//   final DateTime monday = now.subtract(Duration(days: currentWeekday - 1));
//
//   final Map<String, InverterDataModel> mapped = {
//     for (var d in data) DateFormat('yyyy-MM-dd').format(d.createdAt): d
//   };
//
//   List<InverterDataModel> result = [];
//
//   for (int i = 0; i < 7; i++) {
//     final date = monday.add(Duration(days: i));
//     final key = DateFormat('yyyy-MM-dd').format(date);
//
//     if (mapped.containsKey(key)) {
//       result.add(mapped[key]!);
//     } else {
//       result.add(InverterDataModel(
//         id: -1,
//         energyConsumed: 0.0,
//         genPower: 0.0,
//         pvVoltage: 0.0,
//         outputVoltage: 0.0,
//         outputCurrent: 0.0,
//         macAddress: '',
//         error: 0,
//         deviceName: '',
//         version: '',
//         createdAt: date,
//       ));
//     }
//   }
//   return result;
// }
//
// List<String> _generateCurrentWeekLabels() {
//   DateTime now = DateTime.now();
//   int currentWeekday = now.weekday;
//   DateTime monday = now.subtract(Duration(days: currentWeekday - 1));
//
//   return List.generate(7, (index) {
//     DateTime date = monday.add(Duration(days: index));
//     return DateFormat('EEE').format(date); // Mon, Tue, etc.
//   });
// }
//
// Map<String, double> _mapWeeklyData(List<InverterDataModel> data) {
//   DateTime now = DateTime.now();
//   int currentWeekday = now.weekday;
//   DateTime monday = now.subtract(Duration(days: currentWeekday - 1));
//   Map<String, double> result = {};
//
//   for (int i = 0; i < 7; i++) {
//     DateTime day = monday.add(Duration(days: i));
//     String label = DateFormat('EEE').format(day);
//     result[label] = 0.0;
//   }
//
//   for (var entry in data) {
//     for (int i = 0; i < 7; i++) {
//       DateTime day = monday.add(Duration(days: i));
//       if (_isSameDay(entry.createdAt, day)) {
//         String label = DateFormat('EEE').format(day);
//         result[label] = entry.energyConsumed;
//       }
//     }
//   }
//   return result;
// }
//
// bool _isSameDay(DateTime a, DateTime b) {
//   return a.year == b.year && a.month == b.month && a.day == b.day;
// }
//
// BarChartData _buildWeeklyBarChart(List<InverterDataModel> data) {
//   final labels = _generateCurrentWeekLabels();
//   final energyMap = _mapWeeklyData(data);
//
//   return BarChartData(
//     alignment: BarChartAlignment.spaceAround,
//     maxY: (energyMap.values.reduce((a, b) => a > b ? a : b)) + 2,
//     titlesData: FlTitlesData(
//       leftTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 30,
//           getTitlesWidget: (value, _) => Text(value.toStringAsFixed(0),
//               style: const TextStyle(fontSize: 10)),
//         ),
//       ),
//       bottomTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           getTitlesWidget: (value, _) {
//             int index = value.toInt();
//             if (index >= 0 && index < labels.length) {
//               return Text(labels[index],
//                   style: const TextStyle(fontSize: 12));
//             }
//             return const SizedBox();
//           },
//         ),
//       ),
//       topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//     ),
//     barGroups: List.generate(labels.length, (i) {
//       final label = labels[i];
//       final energy = energyMap[label] ?? 0.0;
//       return BarChartGroupData(
//         x: i,
//         barRods: [
//           BarChartRodData(
//             toY: energy,
//             color: const Color(0xFF2277BB),
//             width: 16,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ],
//       );
//     }),
//     gridData: FlGridData(show: true),
//     borderData: FlBorderData(show: false),
//   );
// }
// }

// class DailyBarChart extends StatelessWidget {
//   final List<InverterDataModel> data;
//
//   const DailyBarChart({Key? key, required this.data}) : super(key: key);
//
//   // Generate labels: Mon, Tue, Wed, ...
//   List<String> _generateWeeklyLabels(DateTime now) {
//     final List<String> labels = [];
//     DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
//     for (int i = 0; i < 7; i++) {
//       labels.add(DateFormat('EEE').format(startOfWeek.add(Duration(days: i))));
//     }
//     return labels;
//   }
//
//   // Aggregate energyConsumed for each day of the week
//   Map<String, double> _aggregateDailyEnergy(List<InverterDataModel> data) {
//     final Map<String, double> dailyEnergy = {};
//     final DateTime now = DateTime.now();
//     final DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
//
//     // Initialize all days with 0
//     for (int i = 0; i < 7; i++) {
//       final date = startOfWeek.add(Duration(days: i));
//       final label = DateFormat('EEE').format(date);
//       dailyEnergy[label] = 0.0;
//     }
//
//     for (var item in data) {
//       final DateTime created = item.createdAt;
//       final DateTime onlyDate =
//           DateTime(created.year, created.month, created.day);
//       if (onlyDate.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
//           onlyDate.isBefore(startOfWeek.add(Duration(days: 7)))) {
//         final label = DateFormat('EEE').format(created);
//         dailyEnergy[label] = (dailyEnergy[label] ?? 0) + item.energyConsumed;
//       }
//     }
//
//     return dailyEnergy;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final labels = _generateWeeklyLabels(DateTime.now());
//     final dailyEnergy = _aggregateDailyEnergy(data);
//     final maxY = (dailyEnergy.values.isEmpty
//             ? 1.0
//             : dailyEnergy.values.reduce((a, b) => a > b ? a : b)) +
//         1;
//
//     return AspectRatio(
//       aspectRatio: 1.3,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: BarChart(
//           BarChartData(
//             alignment: BarChartAlignment.spaceAround,
//             maxY: maxY,
//             titlesData: FlTitlesData(
//               show: true,
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   getTitlesWidget: (value, meta) {
//                     int index = value.toInt();
//                     if (index < 0 || index >= labels.length)
//                       return const SizedBox.shrink();
//                     return Text(labels[index],
//                         style: const TextStyle(fontSize: 10));
//                   },
//                 ),
//               ),
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   reservedSize: 40,
//                   getTitlesWidget: (value, meta) {
//                     return Text('${value.toInt()} kWh',
//                         style: const TextStyle(fontSize: 8));
//                   },
//                 ),
//               ),
//               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               rightTitles:
//                   AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             ),
//             borderData: FlBorderData(show: false),
//             barGroups: List.generate(labels.length, (index) {
//               final label = labels[index];
//               final energy = dailyEnergy[label] ?? 0.0;
//
//               return BarChartGroupData(
//                 x: index,
//                 barRods: [
//                   BarChartRodData(
//                     toY: energy,
//                     width: 16,
//                     borderRadius: BorderRadius.circular(4),
//                     color: Colors.blue,
//                   ),
//                 ],
//               );
//             }),
//             gridData: FlGridData(show: true),
//           ),
//         ),
//       ),
//     );
//   }
// }
