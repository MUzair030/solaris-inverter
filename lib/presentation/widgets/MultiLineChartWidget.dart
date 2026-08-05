import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:threepol_inverter_flutter/app/App_Colors.dart';

import '../../data/models/inverter_data_model.dart';

class MultiLineChartWidget extends StatefulWidget {
  final List<InverterDataModel> dataoverall;

  const MultiLineChartWidget({Key? key, required this.dataoverall})
      : super(key: key);

  @override
  State<MultiLineChartWidget> createState() => _MultiLineChartWidgetState();
}

class _MultiLineChartWidgetState extends State<MultiLineChartWidget> {
  String selectedMetric = "All";

  final List<String> metrics = [
    "All",
    "Units Consumed",
    "Power",
    "Solar Voltage",
    "Output Voltage",
    "Output Current",
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200, // Adjust the size
          child: LineChart(_buildLineChart(widget.dataoverall)),
        ),
        const SizedBox(height: 10),
        _buildLegend(widget.dataoverall),
      ],
    );
  }

  LineChartData _buildLineChart(List<InverterDataModel> inverterData) {
    List<FlSpot> energySpots = [];
    List<FlSpot> genPowerSpots = [];
    List<FlSpot> pvVoltageSpots = [];
    List<FlSpot> outputVoltageSpots = [];
    List<FlSpot> outputCurrentSpots = [];

    Map<int, double> energyData = {};
    Map<int, double> genPowerData = {};
    Map<int, double> pvVoltageData = {};
    Map<int, double> outputVoltageData = {};
    Map<int, double> outputCurrentData = {};

    final Map<int, DateTime> hourToDateTime = {};

    // // Initialize with default values (0) for all hours (0-23)
    // for (int i = 0; i <= item.createdAt.hour; i++) {
    //   energyData[i] = 0;
    //   genPowerData[i] = 0;
    //   pvVoltageData[i] = 0;
    //   outputVoltageData[i] = 0;
    //   outputCurrentData[i] = 0;
    // }

    // final int latestHour = inverterData.isNotEmpty
    //     ? inverterData
    //         .map((e) => e.createdAt.hour)
    //         .reduce((a, b) => a > b ? a : b)
    //     : 0;
    // double interval;
    // if (latestHour <= 5) {
    //   interval = 1;
    // } else if (latestHour <= 10) {
    //   interval = 2;
    // } else {
    //   interval = 5;
    // }

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

    // for (var item in inverterData) {
    // Initialize with default values (0) for all hours (0-23)
    for (int i = 1; i <= 24; i++) {
      energyData[i] = 0;
      genPowerData[i] = 0;
      pvVoltageData[i] = 0;
      outputVoltageData[i] = 0;
      outputCurrentData[i] = 0;
    }
    // }

    // Populate the data maps
    for (var item in inverterData) {
      int hour = item.createdAt.hour;
      energyData[hour] = item.energyConsumed;
      genPowerData[hour] = item.genPower;
      pvVoltageData[hour] = item.pvVoltage;
      outputVoltageData[hour] = item.outputVoltage;
      outputCurrentData[hour] = item.outputCurrent;
      // Capture first DateTime for that hour (only if not already set)
      hourToDateTime.putIfAbsent(hour, () => item.createdAt);
    }

    // Convert data maps into FlSpot lists
    energyData.forEach((hour, value) {
      energySpots.add(FlSpot(hour.toDouble(), value));
    });

    genPowerData.forEach((hour, value) {
      genPowerSpots.add(FlSpot(hour.toDouble(), value));
    });

    pvVoltageData.forEach((hour, value) {
      pvVoltageSpots.add(FlSpot(hour.toDouble(), value));
    });

    outputVoltageData.forEach((hour, value) {
      outputVoltageSpots.add(FlSpot(hour.toDouble(), value));
    });

    outputCurrentData.forEach((hour, value) {
      outputCurrentSpots.add(FlSpot(hour.toDouble(), value));
    });

    String _formatYAxisLabels(double value) {
      if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(1)}B';
      if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
      if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}k';
      return value.toStringAsFixed(0);
    }

    return LineChartData(
      minX: 1,
      // maxX: ((latestHour / interval).ceil() * interval).toDouble(),
      maxX: 24,
      minY: 0,
      // maxY: 5000,
      lineBarsData: [
        _buildLineChartBarData(energySpots, const Color(0xFFFF6B00), "Units Consumed"),
        _buildLineChartBarData(genPowerSpots, Colors.blue, "Power"),
        _buildLineChartBarData(pvVoltageSpots, Colors.orange, "Solar Voltage"),
        _buildLineChartBarData(
            outputVoltageSpots, Colors.purple, "Output Voltage"),
        _buildLineChartBarData(
            outputCurrentSpots, Colors.red, "Output Current"),
      ],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 25,
            // interval: 5000,
            getTitlesWidget: (value, meta) {
              return Text(
                (value.toInt()).toStringAsFixed(0),
                style: const TextStyle(fontSize: 9, color: Colors.white),
              );
            },
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 20,
            getTitlesWidget: (value, meta) {
              return Text(_formatYAxisLabels(value),
                  style: const TextStyle(fontSize: 9, color: AppColors.white));
            },
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 4,
            getTitlesWidget: (value, meta) {
              return Text('', style: const TextStyle(fontSize: 0));
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: interval,
            getTitlesWidget: (value, meta) {
              // return Center(
              //   child: Text(
              //     '${value.toInt()}',
              //     style: const TextStyle(
              //         fontSize: 9,
              //         fontWeight: FontWeight.bold,
              //         color: AppColors.white),
              //   ),
              // );

              // if (value % interval != 0 || value > latestHour) {
              //   return const SizedBox.shrink();
              // }
              final hour = value.toInt();
              final formatted = '${hour.toString().padLeft(1, '0')}';
              return Text(formatted,
                  style: const TextStyle(fontSize: 9, color: AppColors.white));
            },
          ),
        ),
      ),
      gridData: const FlGridData(show: true),
      borderData: FlBorderData(show: false),
      // lineTouchData: LineTouchData(
      //   touchTooltipData: LineTouchTooltipData(
      //     tooltipRoundedRadius: 8,
      //     getTooltipItems: (touchedSpots) {
      //       return touchedSpots.map((spot) {
      //         String title = '';
      //         String units = '';
      //         String dateTime = '';
      //
      //         if (spot.barIndex == 0) {
      //           title = "Units C";
      //           units = " KWh";
      //         } else if (spot.barIndex == 1) {
      //           title = "Power";
      //           units = " KW";
      //         } else if (spot.barIndex == 2) {
      //           title = "Solar V";
      //           units = " VDC";
      //         } else if (spot.barIndex == 3) {
      //           title = "Output V";
      //           units = " VAC";
      //         } else if (spot.barIndex == 4) {
      //           title = "Output C";
      //           units = " A";
      //         }
      //
      //         final int index = spot.x.toInt();
      //         if (index >= 0 && index < inverterData.length) {
      //           final date = inverterData[index].createdAt; // already DateTime
      //           dateTime = DateFormat('MMM dd, yyyy - hh:mm a').format(date);
      //         }
      //
      //         return LineTooltipItem(
      //           '$title: ${spot.y.toStringAsFixed(1)}$units\n$dateTime',
      //           const TextStyle(
      //             color: Colors.white,
      //             fontSize: 12,
      //             fontFeatures: [FontFeature.tabularFigures()],
      //           ),
      //         );
      //         // return LineTooltipItem(
      //         //   '$title: ${spot.y.toStringAsFixed(1)}$units\n',
      //         //   const TextStyle(
      //         //     color: Colors.white,
      //         //     fontSize: 12,
      //         //     fontFeatures: [FontFeature.tabularFigures()],
      //         //   ),
      //         // );
      //       }).toList();
      //     },
      //   ),
      // ),
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBorderRadius: BorderRadius.circular(8),
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          tooltipHorizontalAlignment: FLHorizontalAlignment.center,
          tooltipMargin: 8,
          // getTooltipItems: (touchedSpots) {
          //   return touchedSpots.map((spot) {
          //     String title = '';
          //     String units = '';
          //     String dateTime = '';
          //
          //     switch (spot.barIndex) {
          //       case 0:
          //         title = "Units C";
          //         units = " KWh";
          //         break;
          //       case 1:
          //         title = "Power";
          //         units = " KW";
          //         break;
          //       case 2:
          //         title = "Solar V";
          //         units = " VDC";
          //         break;
          //       case 3:
          //         title = "Output V";
          //         units = " VAC";
          //         break;
          //       case 4:
          //         title = "Output C";
          //         units = " A";
          //         break;
          //     }
          //
          //     final int index = spot.x.toInt();
          //     if (index >= 0 && hourToDateTime.containsKey(index)) {
          //       final date = hourToDateTime[index]!;
          //       dateTime = DateFormat('dd:MMM:yy    hh:mm').format(date);
          //     } else {
          //       dateTime = "N/A";
          //     }
          //
          //     return LineTooltipItem(
          //       '$title: ${spot.y.toStringAsFixed(1)}$units\n$dateTime',
          //       const TextStyle(
          //         color: Colors.white,
          //         fontSize: 11,
          //         fontFeatures: [FontFeature.tabularFigures()],
          //       ),
          //     );
          //   }).toList();
          // },
          getTooltipItems: (touchedSpots) {
            if (touchedSpots.isEmpty) return [];

            final buffer = StringBuffer();
            String dateTime = '';

            final int index = touchedSpots.first.x.toInt();
            if (index >= 0 && hourToDateTime.containsKey(index)) {
              final date = hourToDateTime[index]!;
              dateTime = DateFormat('MMM dd, yy  hh:mm a').format(date);
            } else {
              // dateTime = "N/A";
              dateTime = "";
            }

            // Combine all values into a single text
            for (var spot in touchedSpots) {
              String title = '';
              String units = '';

              switch (spot.barIndex) {
                case 0:
                  title = "Units C";
                  units = " KWh";
                  break;
                case 1:
                  title = "Power";
                  units = " KW";
                  break;
                case 2:
                  title = "Solar V";
                  units = " VDC";
                  break;
                case 3:
                  title = "Output V";
                  units = " VAC";
                  break;
                case 4:
                  title = "Output C";
                  units = " A";
                  break;
              }

              // buffer.writeln('$title: ${spot.y.toStringAsFixed(1)}$units');
              final yValue = spot.y.isNaN || spot.y.isInfinite ? 0.0 : spot.y;
              buffer.writeln('$title: ${yValue.toStringAsFixed(1)}$units');
            }

            buffer.writeln('\n$dateTime');

            // Trick: return one real tooltip + invisible ones
            return touchedSpots.map((spot) {
              if (spot == touchedSpots.first) {
                return LineTooltipItem(
                  buffer.toString(),
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    height: 1.2,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                );
              } else {
                // Transparent placeholders prevent FLChart from hiding the tooltip
                return const LineTooltipItem(
                  '',
                  TextStyle(color: Colors.transparent, fontSize: 0),
                );
              }
            }).toList();
            // return touchedSpots.map((spot) {
            //   if (spot == touchedSpots.first) {
            //     return LineTooltipItem(
            //       buffer.toString(),
            //       const TextStyle(
            //         color: Colors.white,
            //         fontSize: 11,
            //         fontFeatures: [FontFeature.tabularFigures()],
            //       ),
            //     );
            //   } else {
            //     // Return an empty tooltip to keep chart behavior correct
            //     return const LineTooltipItem(
            //         '', TextStyle(color: Colors.transparent));
            //   }
            // }).toList();
          },
        ),
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(
      List<FlSpot> spots, Color color, String label) {
    List<FlSpot> powerSpots = widget.dataoverall
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.genPower))
        .toList();
    return LineChartBarData(
      spots: spots,
      // spots: powerSpots,
      // isCurved: true,
      isCurved: false,
      barWidth: 2,
      color: color,
      isStrokeJoinRound: true,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      // dotData: FlDotData(
      //   show: true,
      //   checkToShowDot: (FlSpot spot, LineChartBarData barData) {
      //     // Show dot only if value is not 0 (or any condition you prefer)
      //     return spot.y != 0;
      //     // return true;
      //   },
      //   getDotPainter:
      //       (FlSpot spot, double xPercentage, LineChartBarData bar, int index,
      //           {double? barWidth}) {
      //     return FlDotCirclePainter(
      //       radius: 2,
      //       color: bar.color ?? Colors.black,
      //     );
      //   },
      // ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.4),
            color.withOpacity(0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildLegend(List<InverterDataModel> inverterData) {
    final latest =
        inverterData.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Wrap(
        spacing: 10, // Space between items
        runSpacing: 5, // Space between lines if wrapped
        alignment: WrapAlignment.center,
        children: [
          _legendItem(
              Colors.orange, "Units Consumed", "${latest.energyConsumed} kWh"),
          _legendItem(const Color(0xFFFF6B00), "Power", "${latest.genPower} KW"),
          _legendItem(Colors.blue, "Solar Voltage", "${latest.pvVoltage} VDC"),
          _legendItem(
              Colors.purple, "Output Voltage", "${latest.outputVoltage} VAC"),
          _legendItem(
              Colors.red, "Output Current", "${latest.outputCurrent} A"),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(text,
                  style: const TextStyle(fontSize: 12, color: AppColors.white)),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}
