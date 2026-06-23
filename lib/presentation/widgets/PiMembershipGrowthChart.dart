import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PiMembershipGrowthChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pi Membership Growth Chart")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text("${value.toInt()}");
                  },
                  reservedSize: 22,
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            gridData: FlGridData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(2019, 5000), // Year 2019 - 5K members
                  FlSpot(2020, 1000000), // Year 2020 - 1M members
                  FlSpot(2021, 10000000), // Year 2021 - 10M members
                  FlSpot(2022, 35000000), // Year 2022 - 35M members
                  FlSpot(2023, 45000000), // Year 2023 - 45M members
                ],
                isCurved: true,
                color: Colors.blue,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                    show: true, color: Colors.blue.withOpacity(0.3)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
