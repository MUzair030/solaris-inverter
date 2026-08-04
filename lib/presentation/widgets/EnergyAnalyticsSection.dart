import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/chart_theme.dart';
import '../../core/network/dio_client.dart';
import '../../data/models/inverter_stats_model.dart';
import '../../data/repositories_impl/inverter_repository_impl.dart';
import '../../domain/usecases/fetch_inverter_stats_usecase.dart';
import '../viewmodels/inverter_stats_viewmodel.dart';
import 'ChartEmptyState.dart';
import 'ZoomableLineChart.dart';

enum AnalyticsTab { hour, day, week, month, year }

/// Energy analytics with Hour / Day / Week / Month / Year tabs.
///
/// Each tab requests a bucketed series from the backend `/stats` endpoint and
/// renders it as an interactive (zoomable) line chart. Arrow buttons and a
/// calendar move the selected period, and every switch reloads and re-animates
/// the chart.
class EnergyAnalyticsSection extends StatefulWidget {
  final String? macAddress;

  const EnergyAnalyticsSection({super.key, this.macAddress});

  @override
  State<EnergyAnalyticsSection> createState() => _EnergyAnalyticsSectionState();
}

class _EnergyAnalyticsSectionState extends State<EnergyAnalyticsSection> {
  late final InverterStatsViewModel _viewModel;

  AnalyticsTab _tab = AnalyticsTab.hour;
  DateTime _selectedDay = DateTime.now();
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedYear = DateTime.now();

  @override
  void initState() {
    super.initState();
    final dioClient = DioClient();
    final repo = InverterRepositoryImpl(dioClient);
    _viewModel = InverterStatsViewModel(FetchInverterStatsUseCase(repo));
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didUpdateWidget(EnergyAnalyticsSection oldWidget) {
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
    switch (_tab) {
      case AnalyticsTab.hour:
        final s = _dateOnly(_selectedDay);
        return ('hour', s, s);
      case AnalyticsTab.day:
        final y = _selectedMonth.year;
        final m = _selectedMonth.month;
        final start = DateTime(y, m, 1);
        final end = DateTime(y, m, _daysInMonth(y, m));
        return ('day', _dateOnly(start), _dateOnly(end));
      case AnalyticsTab.week:
        final y = _selectedMonth.year;
        final m = _selectedMonth.month;
        final start = DateTime(y, m, 1);
        final end = DateTime(y, m, _daysInMonth(y, m));
        return ('week', _dateOnly(start), _dateOnly(end));
      case AnalyticsTab.month:
        final y = _selectedYear.year;
        return ('month', '$y-01-01', '$y-12-31');
      case AnalyticsTab.year:
        return ('year', null, null);
    }
  }

  String _dateOnly(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  void _shift(int delta) {
    setState(() {
      switch (_tab) {
        case AnalyticsTab.hour:
          _selectedDay = _selectedDay.add(Duration(days: delta));
        case AnalyticsTab.day:
        case AnalyticsTab.week:
          _selectedMonth = DateTime(
            _selectedMonth.year,
            _selectedMonth.month + delta,
            1,
          );
        case AnalyticsTab.month:
          _selectedYear = DateTime(_selectedYear.year + delta);
        case AnalyticsTab.year:
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
      initialDatePickerMode:
          _tab == AnalyticsTab.hour ? DatePickerMode.day : DatePickerMode.year,
      helpText: 'Select date',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );
    if (picked == null) return;
    setState(() {
      switch (_tab) {
        case AnalyticsTab.hour:
          _selectedDay = picked;
        case AnalyticsTab.day:
        case AnalyticsTab.week:
          _selectedMonth = DateTime(picked.year, picked.month, 1);
        case AnalyticsTab.month:
          _selectedYear = DateTime(picked.year);
        case AnalyticsTab.year:
          break;
      }
    });
    _load();
  }

  DateTime _initialCalendarDate() {
    switch (_tab) {
      case AnalyticsTab.hour:
        return _selectedDay;
      case AnalyticsTab.day:
      case AnalyticsTab.week:
        return _selectedMonth;
      case AnalyticsTab.month:
        return _selectedYear;
      case AnalyticsTab.year:
        return DateTime.now();
    }
  }

  String get _rangeLabel {
    switch (_tab) {
      case AnalyticsTab.hour:
        return DateFormat('EEE, MMM d, yyyy').format(_selectedDay);
      case AnalyticsTab.day:
        return DateFormat('MMMM yyyy').format(_selectedMonth);
      case AnalyticsTab.week:
        return 'Weeks · ${DateFormat('MMM yyyy').format(_selectedMonth)}';
      case AnalyticsTab.month:
        return _selectedYear.year.toString();
      case AnalyticsTab.year:
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
            'Energy Analytics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _periodDropdown(),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_tab != AnalyticsTab.year) ...[
                _IconButton(icon: Icons.chevron_left, onTap: () => _shift(-1)),
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
              if (_tab != AnalyticsTab.year) ...[
                const SizedBox(width: 8),
                _IconButton(icon: Icons.chevron_right, onTap: () => _shift(1)),
                const SizedBox(width: 8),
                _IconButton(
                  icon: Icons.calendar_month_outlined,
                  onTap: _openCalendar,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          ChangeNotifierProvider<InverterStatsViewModel>.value(
            value: _viewModel,
            child: Consumer<InverterStatsViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.stats.isEmpty) {
                  return const SizedBox(
                    height: 200,
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
                    height: 200,
                    child: ChartEmptyState(
                      title: 'Could not load analytics',
                      message: 'Check your connection and try again.',
                      compact: true,
                    ),
                  );
                }
                final spots = _buildSpots(viewModel.stats);
                final labels = _buildLabels(viewModel.stats);
                if (spots.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: ChartEmptyState(
                      title: 'No data for this range',
                      message: 'The inverter has not reported in this period.',
                      compact: true,
                    ),
                  );
                }
                return SizedBox(
                  height: 230,
                  child: ZoomableLineChart(
                    spots: spots,
                    labels: labels,
                    color: ChartTheme.brand,
                    unit: 'kWh',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _buildSpots(List<InverterStatsModel> stats) {
    // Always render the full period as a continuous line. Buckets the backend
    // did not report for that period are plotted as 0 so the chart stays a
    // proper line (day = 24 hours, month = every day, year = 12 months).
    switch (_tab) {
      case AnalyticsTab.hour:
        final hours = <int, double>{};
        for (final item in stats) {
          final hour = int.tryParse(
              item.bucket.length > 13 ? item.bucket.substring(11, 13) : '');
          if (hour != null) hours[hour] = item.energyConsumed;
        }
        return [
          for (var h = 0; h < 24; h++)
            FlSpot(h.toDouble(), hours[h] ?? 0),
        ];
      case AnalyticsTab.day:
        final days = <int, double>{};
        for (final item in stats) {
          final day = int.tryParse(
              item.bucket.length >= 10 ? item.bucket.substring(8, 10) : '');
          if (day != null) days[day] = item.energyConsumed;
        }
        final total = _daysInMonth(_selectedMonth.year, _selectedMonth.month);
        return [
          for (var d = 1; d <= total; d++)
            FlSpot((d - 1).toDouble(), days[d] ?? 0),
        ];
      case AnalyticsTab.week:
        return [
          for (var i = 0; i < stats.length; i++)
            FlSpot(i.toDouble(), stats[i].energyConsumed),
        ];
      case AnalyticsTab.month:
        final months = <int, double>{};
        for (final item in stats) {
          final month = int.tryParse(
              item.bucket.length >= 7 ? item.bucket.substring(5, 7) : '');
          if (month != null) months[month] = item.energyConsumed;
        }
        return [
          for (var m = 1; m <= 12; m++)
            FlSpot((m - 1).toDouble(), months[m] ?? 0),
        ];
      case AnalyticsTab.year:
        return [
          for (var i = 0; i < stats.length; i++)
            FlSpot(i.toDouble(), stats[i].energyConsumed),
        ];
    }
  }

  static const List<String> _hourLabels = [
    '12AM', '', '', '', '4AM', '', '', '', '8AM', '', '', '',
    '12PM', '', '', '', '4PM', '', '', '', '8PM', '', '', '',
  ];

  List<String> _buildLabels(List<InverterStatsModel> stats) {
    switch (_tab) {
      case AnalyticsTab.hour:
        return _hourLabels;
      case AnalyticsTab.day:
        final total = _daysInMonth(_selectedMonth.year, _selectedMonth.month);
        return [for (var d = 1; d <= total; d++) '$d'];
      case AnalyticsTab.week:
        // bucket: "2026-08-03" -> "08/03"
        return [
          for (final item in stats)
            item.bucket.length >= 10
                ? item.bucket.substring(5, 10).replaceAll('-', '/')
                : item.bucket,
        ];
      case AnalyticsTab.month:
        return const [
          'Jan', '', '', 'Apr', '', '', 'Jul', '', '', 'Oct', '', '',
        ];
      case AnalyticsTab.year:
        // bucket: "2026" -> "2026"
        return [
          for (final item in stats)
            item.bucket.length >= 4 ? item.bucket.substring(0, 4) : item.bucket,
        ];
    }
  }

  Widget _periodDropdown() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2E3F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ChartTheme.gridStrong),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AnalyticsTab>(
          value: _tab,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E2130),
          icon: const Icon(Icons.arrow_drop_down, color: ChartTheme.label),
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (value) {
            if (value == null || value == _tab) return;
            setState(() => _tab = value);
            _load();
          },
          items: [
            for (final tab in AnalyticsTab.values)
              DropdownMenuItem<AnalyticsTab>(
                value: tab,
                child: Text(
                  tab.name[0].toUpperCase() + tab.name.substring(1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
