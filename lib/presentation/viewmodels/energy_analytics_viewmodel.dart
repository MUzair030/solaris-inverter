import 'package:flutter/foundation.dart';

import '../../data/models/inverter_stats_model.dart';
import '../../domain/usecases/fetch_inverter_stats_usecase.dart';

/// The periods the shared analytics UI (dashboard card + Analytics screen)
/// can show. [day]/[week]/[month]/[year]/[total] each map to a backend
/// `groupBy` value plus a date range derived from the matching anchor below:
///
/// - [day]   -> groupBy=hour,  range = the single [selectedDay]      (24 hourly buckets)
/// - [week]  -> groupBy=day,   range = the Mon-Sun week containing [selectedDay]
/// - [month] -> groupBy=day,   range = the whole [selectedMonth]     (every day of month)
/// - [year]  -> groupBy=month, range = the whole [selectedYear]      (12 monthly buckets)
/// - [total] -> groupBy=total, no range (one entry per calendar year, lifetime)
///
/// [live] is different in kind: it never calls `/stats` at all. It has no
/// date range or backend fetch - the UI renders it straight from
/// [LiveInverterViewModel]'s rolling poll history instead.
enum AnalyticsPeriod { day, week, month, year, total, live }

/// Single source of truth for the period/date selection and the fetched
/// `/stats` buckets, shared by the dashboard's compact analytics card and the
/// full Analytics screen so they never drift out of sync and never issue
/// duplicate network requests for the same view.
class EnergyAnalyticsViewModel extends ChangeNotifier {
  final FetchInverterStatsUseCase _useCase;

  EnergyAnalyticsViewModel(this._useCase);

  AnalyticsPeriod _period = AnalyticsPeriod.day;
  AnalyticsPeriod get period => _period;

  DateTime _selectedDay = DateTime.now();
  DateTime get selectedDay => _selectedDay;

  DateTime _selectedMonth = DateTime.now();
  DateTime get selectedMonth => _selectedMonth;

  DateTime _selectedYear = DateTime.now();
  DateTime get selectedYear => _selectedYear;

  String? _macAddress;
  String? get macAddress => _macAddress;

  List<InverterStatsBucket> _buckets = [];
  List<InverterStatsBucket> get buckets => _buckets;

  bool isLoading = false;
  String? errorMessage;

  /// Sets (or updates) the device this view model loads stats for. Triggers a
  /// reload only when the mac address actually changes.
  void setMacAddress(String? mac) {
    if (mac == _macAddress) return;
    _macAddress = mac;
    load();
  }

  void setPeriod(AnalyticsPeriod newPeriod) {
    if (newPeriod == _period) return;
    _period = newPeriod;
    notifyListeners();
    // Live never calls /stats - it renders straight from
    // LiveInverterViewModel's poll history, so there's nothing to load here.
    if (newPeriod != AnalyticsPeriod.live) {
      load();
    }
  }

  /// Moves the current period's anchor by [delta] steps (±1 for prev/next
  /// chevrons). No-op for [AnalyticsPeriod.total]/[AnalyticsPeriod.live],
  /// neither of which has a date range.
  void shift(int delta) {
    switch (_period) {
      case AnalyticsPeriod.day:
        _selectedDay = _selectedDay.add(Duration(days: delta));
      case AnalyticsPeriod.week:
        _selectedDay = _selectedDay.add(Duration(days: delta * 7));
      case AnalyticsPeriod.month:
        _selectedMonth =
            DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
      case AnalyticsPeriod.year:
        _selectedYear = DateTime(_selectedYear.year + delta);
      case AnalyticsPeriod.total:
      case AnalyticsPeriod.live:
        return;
    }
    notifyListeners();
    load();
  }

  /// Applies a date picked from a calendar to whichever anchor is relevant
  /// for the current period.
  void setDate(DateTime picked) {
    switch (_period) {
      case AnalyticsPeriod.day:
      case AnalyticsPeriod.week:
        _selectedDay = picked;
      case AnalyticsPeriod.month:
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      case AnalyticsPeriod.year:
        _selectedYear = DateTime(picked.year);
      case AnalyticsPeriod.total:
      case AnalyticsPeriod.live:
        return;
    }
    notifyListeners();
    load();
  }

  /// The date shown in the calendar picker for the current period.
  DateTime get calendarAnchor {
    switch (_period) {
      case AnalyticsPeriod.day:
      case AnalyticsPeriod.week:
        return _selectedDay;
      case AnalyticsPeriod.month:
        return _selectedMonth;
      case AnalyticsPeriod.year:
        return _selectedYear;
      case AnalyticsPeriod.total:
      case AnalyticsPeriod.live:
        return DateTime.now();
    }
  }

  DateTime get _weekStart =>
      _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
  DateTime get _weekEnd => _weekStart.add(const Duration(days: 6));

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Resolves (groupBy, startDate, endDate) for the current period + anchors.
  (String, String?, String?) queryParams() {
    switch (_period) {
      case AnalyticsPeriod.day:
        final s = _dateOnly(_selectedDay);
        return ('hour', s, s);
      case AnalyticsPeriod.week:
        return ('day', _dateOnly(_weekStart), _dateOnly(_weekEnd));
      case AnalyticsPeriod.month:
        final y = _selectedMonth.year;
        final m = _selectedMonth.month;
        final start = DateTime(y, m, 1);
        final end = DateTime(y, m, _daysInMonth(y, m));
        return ('day', _dateOnly(start), _dateOnly(end));
      case AnalyticsPeriod.year:
        final y = _selectedYear.year;
        return ('month', '$y-01-01', '$y-12-31');
      case AnalyticsPeriod.total:
        return ('total', null, null);
      case AnalyticsPeriod.live:
        // Never actually invoked: setPeriod() skips load() for live.
        throw StateError('queryParams() is not valid for AnalyticsPeriod.live');
    }
  }

  /// Fetches the buckets for the current period/anchors/macAddress.
  Future<void> load() async {
    final mac = _macAddress;
    if (mac == null || mac.isEmpty) {
      _buckets = [];
      errorMessage = null;
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final (groupBy, start, end) = queryParams();
      _buckets = await _useCase.execute(
        mac,
        groupBy: groupBy,
        startDate: start,
        endDate: end,
      );
    } catch (e) {
      errorMessage = e.toString();
      _buckets = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
