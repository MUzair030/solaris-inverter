import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/inverter_stats_model.dart';
import '../../domain/usecases/fetch_inverter_stats_usecase.dart';

/// Feeds [TodayProductionCard] from the same bucketed `/stats?groupBy=hour`
/// endpoint the Analytics screen already uses, instead of polling
/// `/getAllInverterData` (a device's *entire* unbounded history) every 2
/// seconds just to compute today's delta and hourly sparkline client-side.
///
/// That old path (still used by `InverterViewModel` elsewhere) doesn't scale:
/// the query and payload both grow with a device's total lifetime row
/// count, forever, and re-running it every 2 seconds per active app session
/// multiplies that cost by every concurrently-open app. Today's card only
/// ever needs today's 24 hourly buckets - a small, bounded, already-
/// server-aggregated response - and doesn't need sub-minute freshness, so
/// this refreshes on a much longer interval.
class TodayProductionViewModel extends ChangeNotifier {
  final FetchInverterStatsUseCase _useCase;

  TodayProductionViewModel(this._useCase);

  static const _refreshInterval = Duration(seconds: 60);

  List<InverterStatsBucket> _todayBuckets = [];
  List<InverterStatsBucket> get todayBuckets => _todayBuckets;

  bool isLoading = false;
  String? errorMessage;

  String? _macAddress;
  Timer? _timer;

  /// Sum of today's real hourly energy deltas - never a sum of the
  /// cumulative meter itself, matching every other energy total in this app.
  double get todayEnergyKwh =>
      _todayBuckets.fold(0.0, (sum, b) => sum + b.energyDeltaKwh);

  /// One value per hour bucket (already zero-padded server-side), for the
  /// card's sparkline.
  List<double> get hourlySparkline =>
      [for (final b in _todayBuckets) b.energyDeltaKwh];

  /// The most recent hour that actually had real samples, or null if the
  /// device hasn't reported at all today.
  DateTime? get lastRealBucketStart {
    for (final b in _todayBuckets.reversed) {
      if (!b.padded) return b.bucketStart;
    }
    return null;
  }

  void setMacAddress(String? mac) {
    if (mac == _macAddress) return;
    _macAddress = mac;
    if (mac == null || mac.isEmpty) {
      _todayBuckets = [];
      notifyListeners();
      return;
    }
    _load();
  }

  Future<void> _load() async {
    final mac = _macAddress;
    if (mac == null || mac.isEmpty) return;

    isLoading = true;
    notifyListeners();
    try {
      final today = _dateOnly(DateTime.now());
      _todayBuckets = await _useCase.execute(
        mac,
        groupBy: 'hour',
        startDate: today,
        endDate: today,
      );
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void startAutoRefresh() {
    stopAutoRefresh();
    _timer = Timer.periodic(_refreshInterval, (_) => _load());
  }

  void stopAutoRefresh() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
