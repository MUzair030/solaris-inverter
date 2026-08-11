import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/chart_theme.dart';
import '../utils/analytics_chart_data.dart';
import '../viewmodels/live_inverter_viewmodel.dart';
import 'ChartEmptyState.dart';
import 'ZoomableLineChart.dart';

/// The "Live" entry in the shared Day/Week/Month/Year/Total/Live analytics
/// selector. Unlike the others, this never calls `/stats` - it plots
/// [LiveInverterViewModel]'s rolling history of the last ~5 minutes of
/// distinct polled readings, updating automatically every time a new reading
/// arrives. Every real metric the device reports gets its own small-multiple
/// chart (Power, Voltage, Output Current), matching the pattern used for the
/// bucketed Day/Week/Month/Year charts - never one dual-axis chart mixing
/// kW/V/A. Rendered identically on the dashboard's compact analytics card
/// and the full Analytics screen - both read the same [LiveInverterViewModel]
/// instance, so there's nothing duplicated here.
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

    final labels = buildLiveLabels(history);

    // Solar/Grid telemetry only exists on newer firmware. A single device's
    // firmware doesn't change mid-session, so "any reading has it" is
    // equivalent to "all readings have it" in practice - gate each series on
    // that rather than plotting a flat, misleadingly-real 0 line for a
    // device/window that never reports it at all.
    final hasSolarPower = history.any((d) => d.solarPower != null);
    final hasGridPower = history.any((d) => d.gridPower != null);
    final hasGridVoltage = history.any((d) => d.gridVoltage != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _chartBlock(
          title: 'Power',
          unit: 'kW',
          height: 200,
          child: ZoomableLineChart(
            series: [
              if (hasSolarPower)
                ChartSeries(
                  label: 'Solar Power',
                  color: ChartTheme.power,
                  spots: buildLiveSpots(history, (d) => d.solarPower ?? 0),
                ),
              if (hasGridPower)
                ChartSeries(
                  label: 'Grid Power',
                  color: ChartTheme.indigo,
                  spots: buildLiveSpots(history, (d) => d.gridPower ?? 0),
                ),
              ChartSeries(
                label: 'Output Power',
                color: ChartTheme.energy,
                // Prefer the real measured value; fall back to the
                // old-firmware field (always populated) for devices that
                // don't report output_power - never a fabricated number.
                spots: buildLiveSpots(
                    history, (d) => d.outputPower ?? d.genPower),
              ),
            ],
            labels: labels,
            unit: 'kW',
          ),
        ),
        const SizedBox(height: 18),
        _chartBlock(
          title: 'Voltage',
          unit: 'V',
          height: 160,
          child: ZoomableLineChart(
            series: [
              ChartSeries(
                label: 'PV Voltage',
                color: ChartTheme.solarVoltage,
                spots: buildLiveSpots(history, (d) => d.pvVoltage),
              ),
              ChartSeries(
                label: 'Output Voltage',
                color: ChartTheme.outputVoltage,
                spots: buildLiveSpots(history, (d) => d.outputVoltage),
              ),
              if (hasGridVoltage)
                ChartSeries(
                  label: 'Grid Voltage',
                  color: ChartTheme.indigo,
                  spots: buildLiveSpots(history, (d) => d.gridVoltage ?? 0),
                ),
            ],
            labels: labels,
            unit: 'V',
          ),
        ),
        const SizedBox(height: 18),
        _chartBlock(
          title: 'Output Current',
          unit: 'A',
          height: 160,
          child: ZoomableLineChart(
            series: [
              ChartSeries(
                label: 'Output Current',
                color: ChartTheme.outputCurrent,
                spots: buildLiveSpots(history, (d) => d.outputCurrent),
              ),
            ],
            labels: labels,
            unit: 'A',
          ),
        ),
      ],
    );
  }

  Widget _chartBlock({
    required String title,
    required String unit,
    required double height,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title ($unit)',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: ChartTheme.label,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(height: height, child: child),
      ],
    );
  }
}
