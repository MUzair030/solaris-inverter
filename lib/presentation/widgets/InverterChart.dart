import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/models/inverter_data_model.dart';
import 'LegendItem.dart';

class InverterChart extends StatelessWidget {
  // final List<InverterDataModel> dataList;
  final List dataList;
  final String filterType; // 'daily', 'weekly', 'monthly', 'yearly'

  const InverterChart({
    Key? key,
    required this.dataList,
    required this.filterType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final Map<int, List<InverterDataModel>> groupedData = {};

    for (var data in dataList) {
      bool isIncluded = false;
      int groupKey = 0;

      switch (filterType) {
        case 'daily':
          isIncluded = _isSameDay(data.createdAt, now);
          groupKey = data.createdAt.hour;
          break;
        case 'weekly':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          isIncluded = data.createdAt
                  .isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
              data.createdAt.isBefore(endOfWeek.add(const Duration(days: 1)));
          groupKey = data.createdAt.weekday; // 1=Mon .. 7=Sun
          break;
        case 'monthly':
          isIncluded = data.createdAt.year == now.year &&
              data.createdAt.month == now.month;
          groupKey = data.createdAt.day; // 1 to 31
          break;
        case 'yearly':
          isIncluded = data.createdAt.year == now.year;
          groupKey = data.createdAt.month; // 1=Jan .. 12=Dec
          break;
      }

      if (isIncluded) {
        groupedData.putIfAbsent(groupKey, () => []).add(data);
      }
    }

    if (groupedData.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    // Sort groups by key (hour/day/month)
    final sortedGroups = groupedData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final barGroups = sortedGroups.map((entry) {
      final key = entry.key;
      final values = entry.value;

      double avg(List<double> list) =>
          list.isEmpty ? 0 : list.reduce((a, b) => a + b) / list.length;

      return BarChartGroupData(
        x: key,
        barRods: [
          BarChartRodData(
              toY: avg(values.map((e) => e.energyConsumed).toList()),
              color: Colors.orange,
              width: 8),
          BarChartRodData(
              toY: avg(values.map((e) => e.genPower).toList()),
              color: Colors.green,
              width: 8),
          BarChartRodData(
              toY: avg(values.map((e) => e.pvVoltage).toList()),
              color: Colors.blue,
              width: 8),
          BarChartRodData(
              toY: avg(values.map((e) => e.outputVoltage).toList()),
              color: Colors.purple,
              width: 8),
          BarChartRodData(
              toY: avg(values.map((e) => e.outputCurrent).toList()),
              color: Colors.red,
              width: 8),
        ],
        barsSpace: 2,
      );
    }).toList();

    final maxY = _getMaxY(groupedData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildLegend(),
        const SizedBox(height: 16),
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: maxY,
              barGroups: barGroups,
              groupsSpace: 16,
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, _) =>
                        _buildBottomLabel(value.toInt()),
                  ),
                ),
                topTitles: AxisTitles(),
                rightTitles: AxisTitles(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomLabel(int key) {
    switch (filterType) {
      case 'daily':
        return Text("$key:00", style: const TextStyle(fontSize: 10));
      case 'weekly':
        const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        return Text(days[key - 1], style: const TextStyle(fontSize: 10));
      case 'monthly':
        return Text("$key", style: const TextStyle(fontSize: 10));
      case 'yearly':
        const months = [
          "Jan",
          "Feb",
          "Mar",
          "Apr",
          "May",
          "Jun",
          "Jul",
          "Aug",
          "Sep",
          "Oct",
          "Nov",
          "Dec"
        ];
        return Text(months[key - 1], style: const TextStyle(fontSize: 10));
      default:
        return const Text("");
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  double _getMaxY(Map<int, List<InverterDataModel>> groupedMap) {
    double maxY = 0;
    for (var list in groupedMap.values) {
      for (var v in list) {
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
    return maxY == 0 ? 10 : maxY * 1.2;
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: const [
        LegendItem(color: Colors.orange, label: 'Energy Consumed'),
        LegendItem(color: Colors.green, label: 'Gen Power'),
        LegendItem(color: Colors.blue, label: 'PV Voltage'),
        LegendItem(color: Colors.purple, label: 'Output Voltage'),
        LegendItem(color: Colors.red, label: 'Output Current'),
      ],
    );
  }
}
