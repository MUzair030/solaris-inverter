import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/inverter_data_model.dart';
import '../../domain/usecases/fetch_latest_inverter_data_usecase.dart';

/// Thin, dashboard-only live view model. Polls `/inverter/latest` every 2
/// seconds and exposes the single latest raw reading.
///
/// This is intentionally separate from [InverterViewModel]: that view model
/// already has its own historical-fetch + offline-detection responsibilities
/// used elsewhere in the app and is left untouched. This one exists solely to
/// drive the dashboard's power-flow diagram and live metrics grid.
class LiveInverterViewModel extends ChangeNotifier {
  final FetchLatestInverterDataUseCase _useCase;

  LiveInverterViewModel(this._useCase);

  /// Rolling window of the most recent *distinct* readings (deduped by id),
  /// oldest first, capped at [_maxHistory]. Backs the "Live" chart. Deduping
  /// matters because polling (every 2s) is far more frequent than the device
  /// typically reports - most polls just return the same latest row again,
  /// and re-plotting that unchanged reading would flatten/mislabel the chart.
  static const int _maxHistory = 150;
  final List<InverterDataModel> _history = [];
  List<InverterDataModel> get history => List.unmodifiable(_history);

  InverterDataModel? _latest;
  InverterDataModel? get latest => _latest;

  bool isLoading = false;
  String? errorMessage;

  String? _macAddress;
  Timer? _timer;

  void setMacAddress(String? mac) {
    if (mac == _macAddress) return;
    _macAddress = mac;
    _history.clear();
    if (mac == null || mac.isEmpty) {
      _latest = null;
      notifyListeners();
      return;
    }
    fetchLatest();
  }

  Future<void> fetchLatest() async {
    final mac = _macAddress;
    if (mac == null || mac.isEmpty) return;

    isLoading = true;
    notifyListeners();
    try {
      _latest = await _useCase.execute(mac);
      errorMessage = null;
      final latest = _latest;
      if (latest != null &&
          (_history.isEmpty || _history.last.id != latest.id)) {
        _history.add(latest);
        while (_history.length > _maxHistory) {
          _history.removeAt(0);
        }
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void startAutoRefresh() {
    stopAutoRefresh();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => fetchLatest());
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
