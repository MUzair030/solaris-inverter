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

  /// True once at least one of today's buckets actually reports the newer
  /// firmware's dedicated solar_units meter (never inferred - the backend
  /// only sets this non-zero from real samples).
  bool get hasSolarData =>
      _todayBuckets.any((b) => b.solarEnergyDeltaKwh != 0);

  /// True once at least one of today's buckets actually reports grid_units.
  bool get hasGridData => _todayBuckets.any((b) => b.gridEnergyDeltaKwh != 0);

  /// Today's real solar production when the device reports the dedicated
  /// solar_units meter; falls back to the total energy_consumed delta for
  /// older-firmware devices, where solar-specific data doesn't exist and
  /// this total is the closest available measurement - the same behavior
  /// this card always had before solar_units existed. Never a sum of a
  /// cumulative meter itself - always a delta, matching every other energy
  /// total in this app.
  double get todayEnergyKwh => hasSolarData
      ? _todayBuckets.fold<double>(0.0, (sum, b) => sum + b.solarEnergyDeltaKwh)
      : _todayBuckets.fold<double>(0.0, (sum, b) => sum + b.energyDeltaKwh);

  /// Today's grid import total, only when the device actually reports it -
  /// null (not 0.0) means "not available", never a fabricated number for a
  /// device/firmware that simply doesn't have a grid meter.
  double? get todayGridImportKwh => hasGridData
      ? _todayBuckets.fold<double>(0.0, (sum, b) => sum + b.gridEnergyDeltaKwh)
      : null;

  /// One value per hour bucket (already zero-padded server-side), for the
  /// card's sparkline - same solar-preferred/total-fallback choice as
  /// [todayEnergyKwh], so the sparkline always matches the headline number.
  List<double> get hourlySparkline => hasSolarData
      ? [for (final b in _todayBuckets) b.solarEnergyDeltaKwh]
      : [for (final b in _todayBuckets) b.energyDeltaKwh];

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
