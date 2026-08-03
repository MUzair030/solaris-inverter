import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/app/App_Colors.dart';
import 'package:threepol_inverter_flutter/app/chart_theme.dart';

import '../../core/network/dio_client.dart';
import '../../data/models/inverter_data_model.dart';
import '../../data/repositories_impl/inverter_repository_impl.dart';
import '../../domain/usecases/fetch_inverter_data_usecase.dart';
import '../../domain/usecases/get_inverter_data_usecase.dart';
import '../viewmodels/SelectedDeviceProvider.dart';
import '../viewmodels/inverter_viewmodel1.dart';
import '../widgets/EnergyDonutChart.dart';
import '../widgets/HeaderWidget.dart';
import '../widgets/InverterChart.dart';
import '../widgets/LineChartWidget.dart';
import '../widgets/MetricBarChart.dart';
import '../widgets/MetricRadarChart.dart';
import '../widgets/PowerGaugeWidget.dart';
import '../widgets/ScatterCorrelationChart.dart';
import '../widgets/WeeklyEnergyBarChart.dart';
import '../widgets/WelcomeWidget.dart';
import 'DailyBarChart.dart';
import 'WeeklyBarChart.dart';

class Statisticsscreen extends StatefulWidget {
  const Statisticsscreen({super.key});

  @override
  State<Statisticsscreen> createState() => _StatisticsscreenState();
}

class _StatisticsscreenState extends State<Statisticsscreen>
    with WidgetsBindingObserver {
  int? selectedBarIndex;
  String selectedFilter = "daily";
  String selectedViz = "gauge";
  bool isDataLoaded = false;
  String? lastLoadedMac;
  String? lastLoadedMonth;

  Map<String, List> allFilterData = {
    "daily": [],
    "weekly": [],
    "monthly": [],
    "yearly": []
  };

  late InverterViewModel1 viewModel;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final dioClient = DioClient();
    final repo = InverterRepositoryImpl(dioClient);
    final useCase = FetchInverterDataUseCase(repo);
    viewModel = InverterViewModel1(useCase);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedDeviceProvider = Provider.of<SelectedDeviceProvider>(context);
    final currentMac = selectedDeviceProvider.mac;
    final currentMonth = DateTime.now().month.toString();

    // If MAC was deselected (null)
    if (currentMac == null && lastLoadedMac != null) {
      lastLoadedMac = null;
      lastLoadedMonth = null;

      // Clear all data
      allFilterData.clear();

      // Optional: preload null to explicitly reset data in UI widgets
      Future.microtask(() => _preloadAllData(null));

      setState(() {});
      return;
    }

    if (currentMac != null && currentMac != lastLoadedMac) {
      lastLoadedMac = currentMac;

      // Check if the month has changed
      if (lastLoadedMonth != currentMonth) {
        // If month has changed, reset weekly data
        allFilterData["weekly"] = [];
        setState(() {});
      }
      // Set last loaded month to the current month
      lastLoadedMonth = currentMonth;

      // Delay the call to avoid build-phase setState/notifyListeners
      Future.microtask(() => _preloadAllData(currentMac));
    }
    // else {
    //   Fluttertoast.showToast(msg: "else");
    //   Future.microtask(() => _preloadAllData(null));
    // }
  }

  Future<void> _preloadAllData(String? mac) async {
    if (mac == null) {
      // If MAC is null (i.e., device deselected), clear the chart data
      allFilterData.clear();
      setState(() => isDataLoaded = false);
      return;
    }
    // Initialize ViewModel here
    final dioClient = DioClient();
    final repo = InverterRepositoryImpl(dioClient);
    final useCase = FetchInverterDataUseCase(repo);
    viewModel = InverterViewModel1(useCase);

    // final viewModel = Provider.of<InverterViewModel1>(context, listen: false);
    setState(() => isDataLoaded = false);

    await viewModel.fetchInverterData("daily", macAddress: mac);
    allFilterData["daily"] = viewModel.inverterData;
    await viewModel.fetchInverterData("weekly", macAddress: mac);
    allFilterData["weekly"] = viewModel.inverterData;
    await viewModel.fetchInverterData("monthly", macAddress: mac);
    allFilterData["monthly"] = viewModel.inverterData;
    await viewModel.fetchInverterData("yearly", macAddress: mac);
    allFilterData["yearly"] = viewModel.inverterData;

    await viewModel.startAutoRefresh(selectedFilter, macAddress: mac);

    setState(() => isDataLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    // final viewModel = Provider.of<InverterViewModel1>(context);
    // List filteredData = allFilterData[selectedFilter] ?? [];
    final filteredData =
        allFilterData[selectedFilter]?.cast<InverterDataModel>() ?? [];
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/bg.png", fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.1)),
          Padding(
            padding:
                const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 70),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 35),
                  const HeaderWidget(),
                  const SizedBox(height: 20),
                  const WelcomeWidget(),
                  const SizedBox(height: 30),

                  // Consumer listens to ViewModel updates
                  ChangeNotifierProvider<InverterViewModel1>.value(
                    value: viewModel,
                    child: Consumer<InverterViewModel1>(
                      builder: (context, viewModel, child) {
                        String displayDate = "No Data Available";

                        // final filteredDataList = allFilterData[selectedFilter];
                        final filteredDataList = allFilterData[selectedFilter]
                                ?.cast<InverterDataModel>() ??
                            [];
                        if (filteredDataList != null &&
                            filteredDataList.isNotEmpty) {
                          // Safely cast to correct model
                          final lastData = filteredDataList.last;
                          displayDate = DateFormat("yyyy-MM-dd")
                              .format(lastData.createdAt);
                        }
                        return SizedBox(
                          height: 350,
                          child: Container(
                            padding: const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 8, right: 10, left: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // Aligns text to the left
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          "Power Usage Over Time",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      _filterDropdown(viewModel),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Expanded(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        selectedFilter == "daily"
                                            // ? BarChart(_buildBarChart1(
                                            //     (allFilterData["weekly"] ?? [])
                                            //         .cast<InverterDataModel>()))
                                            ? LineChartWidget(
                                                inverterData: filteredData,
                                              )
                                            : BarChart(
                                                _buildBarChart(filteredData),
                                              ),
                                      ],
                                    ),
                                  ),
                                  selectedFilter == "daily"
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10, left: 10),
                                          child: Text(
                                            displayDate,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.white),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 10, left: 10),
                                          child: Column(
                                            children: [
                                              if (displayDate ==
                                                  "No Data Available")
                                                const Text(
                                                  "No Data Available",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: AppColors.white),
                                                ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _visualizationsSection(filteredData),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _generateWeeklyLabels1() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    return List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return DateFormat('EEE').format(date); // Mon, Tue, Wed, ...
    });
  }

  Map<String, double> _generateWeeklyEnergyData1(
      List<InverterDataModel> dataList) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday

    final Map<String, double> weekData = {};

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final label = DateFormat('EEE').format(date); // Mon, Tue...
      weekData[label] = 0.0;
    }

    for (var data in dataList) {
      final label = DateFormat('EEE').format(data.createdAt);
      if (weekData.containsKey(label)) {
        weekData[label] = data.energyConsumed;
      }
    }

    return weekData;
  }

  BarChartData _buildBarChart1(List<InverterDataModel> inverterData) {
    final labels = _generateWeeklyLabels1(); // Mon to Sun
    final weekData =
        _generateWeeklyEnergyData1(inverterData); // Map<String, double>

    String currentLabel = _getFormattedLabel(DateTime.now());

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: (weekData.values.isNotEmpty)
          ? weekData.values.reduce((a, b) => a > b ? a : b) + 1
          : 10,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < labels.length) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedBarIndex = value.toInt();
                    });
                  },
                  child: Transform.rotate(
                    angle: 35 * 3.1415926535 / 180,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: Text(
                          labels[value.toInt()],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: labels[value.toInt()] == currentLabel
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: labels[value.toInt()] == currentLabel
                                ? AppColors.blue
                                : Colors.white,
                          ),
                        ),
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
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              double min = meta.min;
              double max = meta.max;
              double mid = (min + max) / 2;

              // Round values to 1 decimal place for comparison
              double round(double val) => double.parse(val.toStringAsFixed(1));
              double rVal = round(value);
              double rMin = round(min);
              double rMax = round(max);
              double rMid = round(mid);

              if (rVal == rMin || rVal == rMid || rVal == rMax) {
                return Text(
                  '${value.toInt()} kWh',
                  style: const TextStyle(fontSize: 8, color: AppColors.white),
                );
              } else {
                return const SizedBox.shrink();
              }

              //   if (value % 10 == 0) {
              //     return Text(
              //       '${value.toInt()} kWh',
              //       style: const TextStyle(fontSize: 8, color: AppColors.white),
              //     );
              //   } else {
              //     return const SizedBox.shrink();
              //   }
            },

            // Use a calculated interval to include mid-point
            interval: null, // Let FLChart auto pick ticks
          ),
        ),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: true),
      borderData: FlBorderData(show: false),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => AppColors.blue,
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
      barGroups: List.generate(7, (index) {
        final label = labels[index];
        final value = weekData[label] ?? 0.0;
        // List<BarChartGroupData> barGroups = labels.asMap().entries.map((entry) {
        //   int index = entry.key;
        //   String label = entry.value;
        //   double totalEnergy = energyData[label] ?? 0.0;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value,
              width: 25,
              color: const Color(0xFFFF6B00),
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: weekData.values.reduce((a, b) => a > b ? a : b) + 1,
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _visualizationsSection(List<InverterDataModel> data) {
    const vizOptions = [
      ('gauge', Icons.speed_outlined, 'Gauge'),
      ('donut', Icons.donut_large_outlined, 'Donut'),
      ('radar', Icons.radar, 'Radar'),
      ('scatter', Icons.scatter_plot_outlined, 'Scatter'),
      ('bars', Icons.bar_chart_outlined, 'Bars'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Visualizations",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: vizOptions.map((option) {
                final key = option.$1;
                final icon = option.$2;
                final label = option.$3;
                final isActive = selectedViz == key;
                return GestureDetector(
                  onTap: () => setState(() => selectedViz = key),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? ChartTheme.brand : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? ChartTheme.brand
                            : ChartTheme.gridStrong,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 14,
                          color: isActive ? Colors.white : ChartTheme.label,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? Colors.white
                                : ChartTheme.label,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          _buildVisualization(data),
        ],
      ),
    );
  }

  Widget _buildVisualization(List<InverterDataModel> data) {
    switch (selectedViz) {
      case 'donut':
        return _buildDonut(data);
      case 'radar':
        return _buildRadar(data);
      case 'scatter':
        return _buildScatter(data);
      case 'bars':
        return _buildMetricBars(data);
      case 'gauge':
      default:
        return _buildGauge(data);
    }
  }

  Widget _buildGauge(List<InverterDataModel> data) {
    double latestPower = data.isNotEmpty ? data.last.genPower : 0;
    double maxKw = 0;
    final devicePower = Provider.of<SelectedDeviceProvider>(context).power;
    if (devicePower != null && devicePower > 0) {
      maxKw = devicePower / 1000.0;
    }
    if (maxKw <= 0) {
      maxKw = data.fold(0.0, (m, d) => d.genPower > m ? d.genPower : m) * 1.1;
    }
    if (maxKw <= 0) maxKw = 1;
    return PowerGaugeWidget(
      value: latestPower,
      max: maxKw,
      subtitle: data.isNotEmpty
          ? DateFormat('HH:mm').format(data.last.createdAt)
          : 'Live',
    );
  }

  Widget _buildDonut(List<InverterDataModel> data) {
    double sumInRange(int from, int to) => data
        .where((e) => e.createdAt.hour >= from && e.createdAt.hour < to)
        .fold(0.0, (s, e) => s + e.energyConsumed);
    final segments = [
      DonutSegment(
        label: 'Night',
        value: sumInRange(0, 6),
        color: ChartTheme.indigo,
      ),
      DonutSegment(
        label: 'Morning',
        value: sumInRange(6, 12),
        color: ChartTheme.power,
      ),
      DonutSegment(
        label: 'Afternoon',
        value: sumInRange(12, 18),
        color: ChartTheme.brand,
      ),
      DonutSegment(
        label: 'Evening',
        value: sumInRange(18, 24),
        color: ChartTheme.cyan,
      ),
    ];
    return EnergyDonutChart(segments: segments);
  }

  Widget _buildRadar(List<InverterDataModel> data) {
    if (data.isEmpty) return const MetricRadarChart(metrics: []);
    double maxOf(double Function(InverterDataModel) f) => data.fold(
        0.0, (m, d) => f(d) > m ? f(d) : m);
    final maxEnergy = maxOf((d) => d.energyConsumed);
    final maxGen = maxOf((d) => d.genPower);
    final maxPv = maxOf((d) => d.pvVoltage);
    final maxOutV = maxOf((d) => d.outputVoltage);
    final maxOutA = maxOf((d) => d.outputCurrent);
    final last = data.last;
    return MetricRadarChart(
      metrics: [
        RadarMetric(
          label: 'Energy',
          value: last.energyConsumed,
          max: maxEnergy <= 0 ? 1 : maxEnergy,
        ),
        RadarMetric(
          label: 'Power',
          value: last.genPower,
          max: maxGen <= 0 ? 1 : maxGen,
        ),
        RadarMetric(
          label: 'PV V',
          value: last.pvVoltage,
          max: maxPv <= 0 ? 1 : maxPv,
        ),
        RadarMetric(
          label: 'Out V',
          value: last.outputVoltage,
          max: maxOutV <= 0 ? 1 : maxOutV,
        ),
        RadarMetric(
          label: 'Out A',
          value: last.outputCurrent,
          max: maxOutA <= 0 ? 1 : maxOutA,
        ),
      ],
    );
  }

  Widget _buildScatter(List<InverterDataModel> data) {
    final points = data
        .map((d) => ScatterPoint(
              x: d.outputVoltage,
              y: d.outputCurrent,
              label:
                  '${d.outputVoltage.toStringAsFixed(1)} V · ${d.outputCurrent.toStringAsFixed(1)} A',
            ))
        .toList();
    return ScatterCorrelationChart(points: points);
  }

  Widget _buildMetricBars(List<InverterDataModel> data) {
    if (data.isEmpty) return const MetricBarChart(items: []);
    final last = data.last;
    return MetricBarChart(
      items: [
        MetricBarItem(
          label: 'Units Consumed',
          value: last.energyConsumed,
          unit: 'kWh',
          color: ChartTheme.energy,
        ),
        MetricBarItem(
          label: 'Generation Power',
          value: last.genPower,
          unit: 'kW',
          color: ChartTheme.power,
        ),
        MetricBarItem(
          label: 'Solar Voltage',
          value: last.pvVoltage,
          unit: 'V',
          color: ChartTheme.solarVoltage,
        ),
        MetricBarItem(
          label: 'Output Voltage',
          value: last.outputVoltage,
          unit: 'V',
          color: ChartTheme.outputVoltage,
        ),
        MetricBarItem(
          label: 'Output Current',
          value: last.outputCurrent,
          unit: 'A',
          color: ChartTheme.outputCurrent,
        ),
      ],
    );
  }

  Widget _filterDropdown(InverterViewModel1 viewModel) {    List<String> filters = ["daily", "weekly", "monthly", "yearly"];
    Map<String, String> filterLabels = {
      "daily": "Daily",
      "weekly": "Weekly",
      "monthly": "Monthly",
      "yearly": "Yearly"
    };
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(50),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFilter,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: AppColors.white,
          ),
          dropdownColor: AppColors.card,
          onChanged: (String? newValue) {
            setState(() {
              selectedFilter = newValue!;
            });
          },
          items: filters.map<DropdownMenuItem<String>>((String filter) {
            return DropdownMenuItem<String>(
              value: filter,
              child: Text(
                filterLabels[filter]!,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      filter == selectedFilter ? AppColors.blue : Colors.white,
                  fontWeight: filter == selectedFilter
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  BarChartData _buildBarChart(List inverterData) {
    // Map<String, double> energyData = {};
    // List<String> labels = _generateLabels();
    String currentLabel = _getFormattedLabel(DateTime.now());
    DateTime now = DateTime.now();
    List<String> labels = selectedFilter == "weekly"
        ? _generateWeeklyLabels(now)
        : _generateLabels();
    // List<String> labels = selectedFilter == "weekly"
    //     ? _generateWeeklyLabels(now)
    //     : selectedFilter == "daily"
    //         ? _generateDailyLabels(now)
    //         : _generateLabels(); // fallback

    // Initialize with zero
    Map<String, double> energyData = {
      for (var label in labels) label: 0.0,
    };

    for (var label in labels) {
      // energyData = {};
      energyData[label] = 0.0;
    }

    // Only keep current month's data
    // List filteredData = inverterData.where((item) {
    //   return item.createdAt.month == now.month &&
    //       item.createdAt.year == now.year;
    // }).toList();

    // for (var item in filteredData) {
    //   String key = _getFormattedLabel(item.createdAt!); // should return like 'Week 1'
    //   if (energyData.containsKey(key)) {
    //     energyData[key] = item.energyConsumed;
    //   }
    // }

    // Filter data
    List filteredData = inverterData.where((item) {
      return selectedFilter == "weekly"
          ? item.createdAt.month == now.month && item.createdAt.year == now.year
          : true;
    }).toList();

    // new code
    // List filteredData = inverterData.where((item) {
    //   DateTime createdAt = item.createdAt;
    //   if (selectedFilter == "weekly") {
    //     return createdAt.month == now.month && createdAt.year == now.year;
    //   } else if (selectedFilter == "daily") {
    //     DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    //     DateTime sunday = monday.add(const Duration(days: 6));
    //     return createdAt.isAfter(monday.subtract(const Duration(days: 1))) &&
    //         createdAt.isBefore(sunday.add(const Duration(days: 1)));
    //   } else {
    //     return true;
    //   }
    // }).toList();

    // Aggregate energy
    for (var item in filteredData) {
      String key = _getFormattedLabel(item.createdAt);
      // if (energyData.containsKey(key)) {
      energyData[key] = (energyData[key] ?? 0) + item.energyConsumed;
      // }
    }
    // // Populate actual data from API
    // for (var item in inverterData) {
    //   String key = _getFormattedLabel(item.createdAt!);
    //   energyData[key] = item.energyConsumed;
    //   // energyData[key] = (energyData[key] ?? 0) + item.energyConsumed;
    // }

    double maxVal = 10;
    for (final e in energyData.values) {
      if (e > maxVal) maxVal = e;
    }
    final double niceMax = maxVal * 1.2;

    List<BarChartGroupData> barGroups = labels.asMap().entries.map((entry) {
      int index = entry.key;
      String label = entry.value;
      double totalEnergy = energyData[label] ?? 0.0;
      final bool isSelected = selectedBarIndex == index;
      final bool isCurrent = label == currentLabel;
      final Color barColor = totalEnergy > 0
          ? (isSelected || isCurrent
              ? ChartTheme.brand
              : ChartTheme.brand.withValues(alpha: 0.72))
          : ChartTheme.gridStrong;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: totalEnergy,
            width: isSelected ? 20 : 13,
            color: barColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
            label: BarChartRodLabel(
              show: totalEnergy > 0 && (isSelected || isCurrent),
              text: ChartTheme.formatCompact(totalEnergy),
              style: const TextStyle(
                fontSize: 9,
                color: ChartTheme.label,
                fontWeight: FontWeight.w600,
              ),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: niceMax,
              color: ChartTheme.grid,
            ),
          ),
        ],
      );
    }).toList();

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: niceMax,
      barGroups: barGroups,
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 46,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index < 0 || index >= labels.length) {
                return const SizedBox.shrink();
              }
              final String label = labels[index];
              final bool isCurrent = label == currentLabel;
              return GestureDetector(
                onTap: () => setState(() => selectedBarIndex = index),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label.contains('\n')
                            ? label.split('\n')[0]
                            : label,
                        style: TextStyle(
                          fontSize: isCurrent ? 10 : 9,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.w500,
                          color: isCurrent
                              ? ChartTheme.brand
                              : ChartTheme.label,
                        ),
                      ),
                      if (label.contains('\n'))
                        Text(
                          label.split('\n')[1],
                          style: const TextStyle(
                            fontSize: 8,
                            color: ChartTheme.labelMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: niceMax / 4,
            getTitlesWidget: (value, meta) {
              return Text(
                '${ChartTheme.formatCompact(value)} kWh',
                style: ChartTheme.axisLabelStyle,
              );
            },
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: niceMax / 4,
        getDrawingHorizontalLine: (_) => const FlLine(
          color: ChartTheme.grid,
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          left: BorderSide(color: ChartTheme.gridStrong),
          bottom: BorderSide(color: ChartTheme.gridStrong),
        ),
      ),
      barTouchData: BarTouchData(
        enabled: true,
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          if (event is FlTapUpEvent && barTouchResponse?.spot != null) {
            setState(() {
              selectedBarIndex = barTouchResponse!.spot!.touchedBarGroupIndex;
            });
          }
        },
        touchTooltipData: BarTouchTooltipData(
          tooltipBorderRadius: BorderRadius.circular(10),
          getTooltipColor: (_) => const Color(0xF21A1A26),
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          tooltipMargin: 10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            if (selectedBarIndex != groupIndex) return null;
            final String label =
                groupIndex < labels.length ? labels[groupIndex] : '';
            return BarTooltipItem(
              '${label.replaceAll('\n', ' ')}\n'
              '${rod.toY.toStringAsFixed(2)} kWh',
              const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
      ),
    );
  }

  // List<String> _generateWeeklyLabels(DateTime now) {
  //   List<String> labels = [];
  //   int daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
  //   int totalWeeks = ((daysInMonth - 1) ~/ 7) + 1;
  //
  //   for (int i = 1; i <= totalWeeks; i++) {
  //     DateTime monthDate = DateTime(now.month, i);
  //     String label = DateFormat("MMM").format(monthDate);
  //     labels.add("$daysInMonth Week $i");
  //   }
  //
  //   return labels;
  // }

  List<String> _generateWeeklyLabels(DateTime now) {
    List<String> labels = [];
    int daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    int totalWeeks = ((daysInMonth - 1) ~/ 7) + 1;

    for (int i = 1; i <= totalWeeks; i++) {
      // Calculate the first day of the week
      DateTime firstDayOfWeek = DateTime(now.year, now.month, (i - 1) * 7 + 1);

      // If it's the last week, check if it spans into next month
      if (i == totalWeeks) {
        DateTime lastDayOfWeek = DateTime(now.year, now.month, daysInMonth);

        // Format the label based on whether the week spans across months
        if (firstDayOfWeek.month != lastDayOfWeek.month) {
          String startMonth = DateFormat("MMM").format(firstDayOfWeek);
          String endMonth = DateFormat("MMM").format(lastDayOfWeek);
          labels.add("Week $i ($startMonth-$endMonth)");
        } else {
          String month = DateFormat("MMM").format(firstDayOfWeek);
          labels.add("$month Week $i");
        }
      } else {
        String month = DateFormat("MMM").format(firstDayOfWeek);
        labels.add("$month Week $i");
      }
    }

    return labels;
  }

  List<String> _generateDailyLabels(DateTime now) {
    List<String> labels = [];
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    for (int i = 0; i < 7; i++) {
      DateTime day = monday.add(Duration(days: i));
      labels.add(DateFormat.E().format(day)); // Mon, Tue, ...
    }

    return labels;
  }

  List<String> _generateLabels() {
    List<String> labels = [];
    DateTime now = DateTime.now();

    switch (selectedFilter) {
      case "daily":
        DateFormat.E().format(now);
        // labels = _generateDailyLabels(now);
        // labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        break;

      case "weekly":
        for (int i = 3; i >= 0; i--) {
          DateTime weekStartDate = now.subtract(Duration(days: i * 7));
          String weekNumber = DateFormat('w').format(weekStartDate);
          String year = DateFormat('y').format(weekStartDate);
          labels.add("Week $weekNumber");
        }
        break;

      case "monthly":
        for (int i = 1; i <= 12; i++) {
          DateTime monthDate = DateTime(now.year, i);
          String year = DateFormat('y').format(monthDate);
          String label = DateFormat("MMM\n$year").format(monthDate);
          labels.add(label);
        }
        break;

      case "yearly":
        labels = [
          (now.year - 2).toString(),
          (now.year - 1).toString(),
          now.year.toString(),
          (now.year + 1).toString(),
          (now.year + 2).toString(),
        ];
        break;
    }

    return labels;
  }

  String _getFormattedLabel(DateTime date) {
    switch (selectedFilter) {
      case "daily":
        return DateFormat.E().format(date);

      case "weekly":
        int weekOfMonth = ((date.day - 1) ~/ 7) + 1;
        String month = DateFormat("MMM").format(date);
        return "$month Week $weekOfMonth";

      case "monthly":
        String year = DateFormat('y').format(date);
        return DateFormat("MMM\n$year").format(date);

      case "yearly":
        return DateFormat.y().format(date);

      default:
        return DateFormat.yMd().format(date);
    }
  }
}
