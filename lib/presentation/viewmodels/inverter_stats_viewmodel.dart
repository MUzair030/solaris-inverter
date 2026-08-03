import 'package:flutter/foundation.dart';

import '../../data/models/inverter_stats_model.dart';
import '../../domain/usecases/fetch_inverter_stats_usecase.dart';

/// Loads aggregated stats buckets for the analytics charts.
class InverterStatsViewModel extends ChangeNotifier {
  final FetchInverterStatsUseCase _useCase;

  List<InverterStatsModel> _stats = [];
  bool isLoading = false;
  String? errorMessage;

  InverterStatsViewModel(this._useCase);

  List<InverterStatsModel> get stats => _stats;

  Future<void> fetchStats(
    String macAddress, {
    required String groupBy,
    String? startDate,
    String? endDate,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      _stats = await _useCase.execute(
        macAddress,
        groupBy: groupBy,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      errorMessage = e.toString();
      _stats = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
