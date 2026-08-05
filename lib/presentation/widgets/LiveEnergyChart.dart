import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/chart_theme.dart';
import '../utils/analytics_chart_data.dart';
import '../viewmodels/live_inverter_viewmodel.dart';
import 'ChartEmptyState.dart';
import 'ZoomableLineChart.dart';

/// The "Live" entry in the shared Day/Week/Month/Year/Total/Live analytics
/// selector. Unlike the other periods, this never calls `/stats` - it plots
/// [LiveInverterViewModel]'s rolling history of the last ~5 minutes of
/// distinct polled readings (Generation Power), updating automatically every
/// time a new reading arrives. Rendered identically on the dashboard's
/// compact analytics card and the full Analytics screen - both read the same
/// [LiveInverterViewModel] instance, so there's nothing duplicated here.
class LiveEnergyChart extends StatelessWidget {
  const LiveEnergyChart({super.key});

  @override
  Widget build(BuildContext context) {
    final live = context.watch<LiveInverterViewModel>();
    final history = live.history;

    if (history.length < 2) {
      return const SizedBox(
        height: 200,
        child: ChartEmptyState(
          title: 'Waiting for live readings',
          message: 'The chart will start plotting as the inverter reports.',
          compact: true,
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ZoomableLineChart(
        spots: buildLiveSpots(history, (d) => d.genPower),
        labels: buildLiveLabels(history),
        color: ChartTheme.power,
        unit: 'kW',
      ),
    );
  }
}
