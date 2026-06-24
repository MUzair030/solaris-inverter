import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:threepol_inverter_flutter/app/app_colors.dart';

import '../../data/models/inverter_data_model.dart';

class PowerTrendChartWidget extends StatelessWidget {
  final List<InverterDataModel> dataoverall;
  const PowerTrendChartWidget({super.key, required this.dataoverall});

  @override
  Widget build(BuildContext context) {
    final spotsMap = _generateSpots(dataoverall);

    // Find the latest hour available in data
    final lastHour = dataoverall.isEmpty
        ? 0
        : dataoverall
            .map((e) => e.createdAt.hour)
            .reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: lastHour.toDouble(), // Use latest hour only
                minY: 0,
                lineBarsData: [
                  _buildLine(spotsMap['energy']!, Colors.deepPurple),
                  _buildLine(spotsMap['gen']!, Colors.red),
                  _buildLine(spotsMap['pv']!, const Color(0xFFFF6B00)),
                  _buildLine(spotsMap['outputV']!, Colors.orange),
                  _buildLine(spotsMap['outputC']!, Colors.blue),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) => Text("${value.toInt()}h",
                          style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 40,
                      getTitlesWidget: (value, _) => Text("${value.toInt()}",
                          style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 20,
                  verticalInterval: 1,
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(),
                    bottom: BorderSide(),
                  ),
                ),
                lineTouchData: LineTouchData(enabled: true),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: const [
            _Legend(color: Colors.deepPurple, label: "Energy"),
            _Legend(color: Colors.red, label: "Gen"),
            _Legend(color: const Color(0xFFFF6B00), label: "PV"),
            _Legend(color: Colors.orange, label: "Output V"),
            _Legend(color: Colors.blue, label: "Output C"),
          ],
        ),
      ],
    );
  }

  LineChartBarData _buildLine(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
    );
  }

  Map<String, List<FlSpot>> _generateSpots(List<InverterDataModel> data) {
    Map<int, List<InverterDataModel>> groupedByHour = {};
    for (var d in data) {
      int hour = d.createdAt.hour;
      groupedByHour.putIfAbsent(hour, () => []).add(d);
    }

    final List<FlSpot> energy = [];
    final List<FlSpot> gen = [];
    final List<FlSpot> pv = [];
    final List<FlSpot> outputV = [];
    final List<FlSpot> outputC = [];

    final sortedHours = groupedByHour.keys.toList()..sort();

    for (int hour in sortedHours) {
      var hourData = groupedByHour[hour] ?? [];

      double avg(List<double> values) =>
          values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;

      energy.add(FlSpot(hour.toDouble(),
          avg(hourData.map((e) => e.energyConsumed).toList())));
      gen.add(FlSpot(
          hour.toDouble(), avg(hourData.map((e) => e.genPower).toList())));
      pv.add(FlSpot(
          hour.toDouble(), avg(hourData.map((e) => e.pvVoltage).toList())));
      outputV.add(FlSpot(
          hour.toDouble(), avg(hourData.map((e) => e.outputVoltage).toList())));
      outputC.add(FlSpot(
          hour.toDouble(), avg(hourData.map((e) => e.outputCurrent).toList())));
    }

    return {
      'energy': energy,
      'gen': gen,
      'pv': pv,
      'outputV': outputV,
      'outputC': outputC,
    };
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
