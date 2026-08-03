import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/chart_theme.dart';
import '../../core/network/dio_client.dart';
import '../../data/models/inverter_stats_model.dart';
import '../../data/repositories_impl/inverter_repository_impl.dart';
import '../../domain/usecases/fetch_inverter_stats_usecase.dart';
import '../viewmodels/SelectedDeviceProvider.dart';
import '../viewmodels/inverter_stats_viewmodel.dart';
import 'ChartEmptyState.dart';
import 'EnergyDonutChart.dart';
import 'MetricBarChart.dart';
import 'MetricRadarChart.dart';
import 'PowerGaugeWidget.dart';
import 'ScatterCorrelationChart.dart';

enum VizPeriod { hour, day, week, month, year }

/// Visualization charts (Gauge / Donut / Radar / Scatter / Bars) driven by the
/// backend `/stats` endpoint with a Hour / Day / Week / Month / Year period
/// selector, mirroring the Energy Analytics section.
class EnergyVisualizationsSection extends StatefulWidget {
  final String? macAddress;

  const EnergyVisualizationsSection({super.key, this.macAddress});

  @override
  State<EnergyVisualizationsSection> createState() =>
      _EnergyVisualizationsSectionState();
}

class _EnergyVisualizationsSectionState
    extends State<EnergyVisualizationsSection> {
  late final InverterStatsViewModel _viewModel;

  VizPeriod _period = VizPeriod.hour;
  String _selectedViz = 'gauge';
  DateTime _selectedDay = DateTime.now();
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedYear = DateTime.now();

  static const List<(String, IconData, String)> _vizOptions = [
    ('gauge', Icons.speed_outlined, 'Gauge'),
    ('donut', Icons.donut_large_outlined, 'Donut'),
    ('radar', Icons.radar, 'Radar'),
    ('scatter', Icons.scatter_plot_outlined, 'Scatter'),
    ('bars', Icons.bar_chart_outlined, 'Bars'),
  ];

  @override
  void initState() {
    super.initState();
    final dioClient = DioClient();
    final repo = InverterRepositoryImpl(dioClient);
    _viewModel = InverterStatsViewModel(FetchInverterStatsUseCase(repo));
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didUpdateWidget(EnergyVisualizationsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.macAddress != widget.macAddress) {
      _load();
    }
  }

  void _load() {
    final mac = widget.macAddress;
    if (mac == null || mac.isEmpty) return;
    final (groupBy, start, end) = _queryParams();
    _viewModel.fetchStats(mac, groupBy: groupBy, startDate: start, endDate: end);
  }

  (String, String?, String?) _queryParams() {
    switch (_period) {
      case VizPeriod.hour:
        final s = _dateOnly(_selectedDay);
        return ('hour', s, s);
      case VizPeriod.day:
        final y = _selectedMonth.year;
        final m = _selectedMonth.month;
        return ('day', _dateOnly(DateTime(y, m, 1)),
            _dateOnly(DateTime(y, m, _daysInMonth(y, m))));
      case VizPeriod.week:
        final y = _selectedMonth.year;
        final m = _selectedMonth.month;
        return ('week', _dateOnly(DateTime(y, m, 1)),
            _dateOnly(DateTime(y, m, _daysInMonth(y, m))));
      case VizPeriod.month:
        final y = _selectedYear.year;
        return ('month', '$y-01-01', '$y-12-31');
      case VizPeriod.year:
        return ('year', null, null);
    }
  }

  String _dateOnly(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  void _shift(int delta) {
    setState(() {
      switch (_period) {
        case VizPeriod.hour:
          _selectedDay = _selectedDay.add(Duration(days: delta));
        case VizPeriod.day:
        case VizPeriod.week:
          _selectedMonth =
              DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
        case VizPeriod.month:
          _selectedYear = DateTime(_selectedYear.year + delta);
        case VizPeriod.year:
          return;
      }
    });
    _load();
  }

  Future<void> _openCalendar() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _initialCalendarDate(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      initialDatePickerMode: _period == VizPeriod.hour
          ? DatePickerMode.day
          : DatePickerMode.year,
      helpText: 'Select date',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );
    if (picked == null) return;
    setState(() {
      switch (_period) {
        case VizPeriod.hour:
          _selectedDay = picked;
        case VizPeriod.day:
        case VizPeriod.week:
          _selectedMonth = DateTime(picked.year, picked.month, 1);
        case VizPeriod.month:
          _selectedYear = DateTime(picked.year);
        case VizPeriod.year:
          break;
      }
    });
    _load();
  }

  DateTime _initialCalendarDate() {
    switch (_period) {
      case VizPeriod.hour:
        return _selectedDay;
      case VizPeriod.day:
      case VizPeriod.week:
        return _selectedMonth;
      case VizPeriod.month:
        return _selectedYear;
      case VizPeriod.year:
        return DateTime.now();
    }
  }

  String get _rangeLabel {
    switch (_period) {
      case VizPeriod.hour:
        return DateFormat('EEE, MMM d, yyyy').format(_selectedDay);
      case VizPeriod.day:
        return DateFormat('MMMM yyyy').format(_selectedMonth);
      case VizPeriod.week:
        return 'Weeks · ${DateFormat('MMM yyyy').format(_selectedMonth)}';
      case VizPeriod.month:
        return _selectedYear.year.toString();
      case VizPeriod.year:
        return 'All Years';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2130),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visualizations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final period in VizPeriod.values)
                _chip(
                  label: period.name[0].toUpperCase() + period.name.substring(1),
                  active: _period == period,
                  onTap: () {
                    setState(() => _period = period);
                    _load();
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_period != VizPeriod.year) ...[
                _iconButton(Icons.chevron_left, () => _shift(-1)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  _rangeLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_period != VizPeriod.year) ...[
                const SizedBox(width: 8),
                _iconButton(Icons.chevron_right, () => _shift(1)),
                const SizedBox(width: 8),
                _iconButton(Icons.calendar_month_outlined, _openCalendar),
              ],
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _vizOptions.map((option) {
                final key = option.$1;
                final icon = option.$2;
                final label = option.$3;
                final isActive = _selectedViz == key;
                return GestureDetector(
                  onTap: () => setState(() => _selectedViz = key),
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
                        color: isActive ? ChartTheme.brand : ChartTheme.gridStrong,
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
                            color: isActive ? Colors.white : ChartTheme.label,
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
          ChangeNotifierProvider<InverterStatsViewModel>.value(
            value: _viewModel,
            child: Consumer<InverterStatsViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.stats.isEmpty) {
                  return const SizedBox(
                    height: 220,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: ChartTheme.brand,
                      ),
                    ),
                  );
                }
                if (viewModel.errorMessage != null && viewModel.stats.isEmpty) {
                  return const SizedBox(
                    height: 220,
                    child: ChartEmptyState(
                      title: 'Could not load visualizations',
                      message: 'Check your connection and try again.',
                      compact: true,
                    ),
                  );
                }
                final stats = viewModel.stats;
                if (stats.isEmpty) {
                  return const SizedBox(
                    height: 220,
                    child: ChartEmptyState(
                      title: 'No data for this range',
                      message: 'The inverter has not reported in this period.',
                      compact: true,
                    ),
                  );
                }
                final total = stats.fold<double>(
                    0.0, (s, e) => s + e.energyConsumed);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total ${total.toStringAsFixed(2)} kWh · ${stats.length} period${stats.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ChartTheme.label,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildVisualization(stats),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualization(List<InverterStatsModel> stats) {
    switch (_selectedViz) {
      case 'donut':
        return _buildDonut(stats);
      case 'radar':
        return _buildRadar(stats);
      case 'scatter':
        return _buildScatter(stats);
      case 'bars':
        return _buildMetricBars(stats);
      case 'gauge':
      default:
        return _buildGauge(stats);
    }
  }

  Widget _buildGauge(List<InverterStatsModel> stats) {
    final last = stats.last;
    double maxKw = 0;
    final devicePower =
        Provider.of<SelectedDeviceProvider>(context).power;
    if (devicePower != null && devicePower > 0) {
      maxKw = devicePower / 1000.0;
    }
    if (maxKw <= 0) {
      maxKw = stats.fold(0.0, (m, s) => s.genPower > m ? s.genPower : m) * 1.1;
    }
    if (maxKw <= 0) maxKw = 1;
    return PowerGaugeWidget(
      value: last.genPower,
      max: maxKw,
      subtitle: _shortLabel(last.bucket),
    );
  }

  Widget _buildDonut(List<InverterStatsModel> stats) {
    final sorted = [...stats]
      ..sort((a, b) => b.energyConsumed.compareTo(a.energyConsumed));
    final top = sorted.take(6).toList();
    final rest =
        sorted.skip(6).fold<double>(0.0, (s, e) => s + e.energyConsumed);
    final segments = <DonutSegment>[
      for (var i = 0; i < top.length; i++)
        DonutSegment(
          label: _shortLabel(top[i].bucket),
          value: top[i].energyConsumed,
          color: ChartTheme.categoricalColors[
              i % ChartTheme.categoricalColors.length],
        ),
      if (rest > 0)
        DonutSegment(
          label: 'Other',
          value: rest,
          color: ChartTheme.gridStrong,
        ),
    ];
    return EnergyDonutChart(segments: segments);
  }

  Widget _buildRadar(List<InverterStatsModel> stats) {
    final last = stats.last;
    double maxOf(double Function(InverterStatsModel) f) =>
        stats.fold(0.0, (m, s) => f(s) > m ? f(s) : m);
    final maxEnergy = maxOf((s) => s.energyConsumed);
    final maxGen = maxOf((s) => s.genPower);
    final maxPv = maxOf((s) => s.pvVoltage);
    final maxOutV = maxOf((s) => s.outputVoltage);
    final maxOutA = maxOf((s) => s.outputCurrent);
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

  Widget _buildScatter(List<InverterStatsModel> stats) {
    final points = stats
        .map((s) => ScatterPoint(
              x: s.outputVoltage,
              y: s.outputCurrent,
              label: '${_shortLabel(s.bucket)} · '
                  '${s.outputVoltage.toStringAsFixed(1)} V · '
                  '${s.outputCurrent.toStringAsFixed(1)} A',
            ))
        .toList();
    return ScatterCorrelationChart(points: points);
  }

  Widget _buildMetricBars(List<InverterStatsModel> stats) {
    final last = stats.last;
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

  String _shortLabel(String bucket) {
    switch (_period) {
      case VizPeriod.hour:
        return bucket.length > 15 ? bucket.substring(11, 16) : bucket;
      case VizPeriod.day:
        return bucket.length >= 10 ? bucket.substring(8, 10) : bucket;
      case VizPeriod.week:
        return bucket.length >= 10
            ? bucket.substring(5, 10).replaceAll('-', '/')
            : bucket;
      case VizPeriod.month:
        if (bucket.length < 7) return bucket;
        final month = int.tryParse(bucket.substring(5, 7));
        if (month == null || month < 1 || month > 12) return bucket;
        return const [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
        ][month - 1];
      case VizPeriod.year:
        return bucket.length >= 4 ? bucket.substring(0, 4) : bucket;
    }
  }

  Widget _chip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? ChartTheme.brand : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? ChartTheme.brand : ChartTheme.gridStrong,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : ChartTheme.label,
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2E3F),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: ChartTheme.label),
      ),
    );
  }
}
