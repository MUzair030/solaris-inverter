import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/chart_theme.dart';
import '../viewmodels/SelectedDeviceProvider.dart';
import '../viewmodels/energy_analytics_viewmodel.dart';
import '../viewmodels/live_inverter_viewmodel.dart';
import '../viewmodels/today_production_viewmodel.dart';
import '../widgets/ChartEmptyState.dart';
import '../widgets/HeaderWidget.dart';
import '../widgets/LiveEnergyChart.dart';
import '../widgets/LiveMetricsGrid.dart';
import '../widgets/PeriodMetricsCharts.dart';
import '../widgets/PowerFlowDiagram.dart';
import '../widgets/SectionCard.dart';
import '../widgets/TodayProductionCard.dart';
import '../widgets/WelcomeWidget.dart';

/// Prefers a real, backend-measured value (e.g. newer firmware's
/// `solar_power`/`output_power`) over a legacy fallback (old-firmware
/// `gen_power`/the voltage*current estimate) - never fabricates a number,
/// just picks the best real one already available. Shared by the power
/// flow diagram and live metrics grid below so the "prefer real, else old
/// value" check isn't repeated inline for every metric.
double _preferReal(double? real, double fallback) => real ?? fallback;

/// Maps the newer firmware's `device_type` enum to a display label. Null for
/// old-firmware devices (field absent) or an unrecognized value - never a
/// guessed/default label.
String? _deviceTypeLabel(int? type) {
  switch (type) {
    case 1:
      return 'Battery-less Inverter';
    case 2:
      return 'Grid-Share Inverter';
    case 3:
      return 'Hybrid Inverter';
    default:
      return null;
  }
}

/// Dashboard: power-flow diagram -> live metrics grid -> today's production
/// -> compact energy analytics, fed by the shared [LiveInverterViewModel],
/// [TodayProductionViewModel] and [EnergyAnalyticsViewModel] instances all
/// owned by the tab shell (`Mainbottomnavigationview`).
class Mainscreen extends StatelessWidget {
  const Mainscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/bg.png", fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.1)),
          Padding(
            padding:
                const EdgeInsets.only(right: 15, left: 15, top: 10, bottom: 110),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 35),
                  const HeaderWidget(),
                  const SizedBox(height: 20),
                  const WelcomeWidget(),
                  const SizedBox(height: 16),
                  const _PowerFlowSection(),
                  const SizedBox(height: 16),
                  const _LiveMetricsSection(),
                  const SizedBox(height: 16),
                  const _TodayProductionSection(),
                  const SizedBox(height: 16),
                  const _CompactAnalyticsSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PowerFlowSection extends StatelessWidget {
  const _PowerFlowSection();

  @override
  Widget build(BuildContext context) {
    final live = context.watch<LiveInverterViewModel>();
    final devicePower = context.watch<SelectedDeviceProvider>().power;
    final latest = live.latest;

    if (latest == null) {
      return const SectionCard(
        title: 'Live Power Flow',
        icon: Icons.bolt,
        accentColor: ChartTheme.brand,
        child: SizedBox(
          height: 160,
          child: ChartEmptyState(
            title: 'Waiting for live data',
            message: 'The power flow will animate once the inverter reports.',
            compact: true,
          ),
        ),
      );
    }

    // Prefer the real newer-firmware values; fall back to the old-firmware
    // fields/estimate exactly as today when a device hasn't reported them.
    final genPowerKw = _preferReal(latest.solarPower, latest.genPower);
    final loadKw = _preferReal(
      latest.outputPower,
      latest.outputVoltage * latest.outputCurrent / 1000.0,
    );
    double flow = 0.4;
    if (devicePower != null && devicePower > 0) {
      flow = (genPowerKw * 1000 / devicePower).clamp(0.0, 1.0);
    }

    final deviceTypeLabel = _deviceTypeLabel(latest.deviceType);

    return SectionCard(
      title: 'Live Power Flow',
      icon: Icons.bolt,
      accentColor: ChartTheme.brand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (deviceTypeLabel != null) ...[
            Text(
              deviceTypeLabel,
              style: const TextStyle(
                fontSize: 11,
                color: ChartTheme.labelMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
          ],
          PowerFlowDiagram(
            genPowerKw: genPowerKw,
            loadKw: loadKw,
            gridPowerKw: latest.gridPower,
            gridVoltage: latest.gridVoltage,
            pvVoltage: latest.pvVoltage,
            outputVoltage: latest.outputVoltage,
            outputCurrent: latest.outputCurrent,
            flow: flow,
          ),
        ],
      ),
    );
  }
}

class _LiveMetricsSection extends StatelessWidget {
  const _LiveMetricsSection();

  @override
  Widget build(BuildContext context) {
    final live = context.watch<LiveInverterViewModel>();
    final latest = live.latest;

    if (latest == null) {
      return const SectionCard(
        title: 'Live Metrics',
        icon: Icons.dashboard_outlined,
        accentColor: ChartTheme.cyan,
        child: SizedBox(
          height: 100,
          child: ChartEmptyState(
            title: 'No live readings yet',
            compact: true,
          ),
        ),
      );
    }

    // Prefer the real newer-firmware values; fall back to the old-firmware
    // fields/estimate exactly as today when a device hasn't reported them.
    final solarPowerKw = _preferReal(latest.solarPower, latest.genPower);
    final loadKw = _preferReal(
      latest.outputPower,
      latest.outputVoltage * latest.outputCurrent / 1000.0,
    );
    final gridPowerKw = latest.gridPower;

    return SectionCard(
      title: 'Live Metrics',
      icon: Icons.dashboard_outlined,
      accentColor: ChartTheme.cyan,
      child: LiveMetricsGrid(
        metrics: [
          LiveMetric(
            label: 'Solar Generation',
            value: solarPowerKw.toStringAsFixed(2),
            unit: 'kW',
            icon: Icons.solar_power_outlined,
            color: ChartTheme.power,
          ),
          LiveMetric(
            label: 'House Load',
            value: loadKw.toStringAsFixed(2),
            unit: 'kW',
            icon: Icons.home_outlined,
            color: ChartTheme.cyan,
          ),
          LiveMetric(
            label: 'PV Voltage',
            value: latest.pvVoltage.toStringAsFixed(1),
            unit: 'V',
            icon: Icons.bolt_outlined,
            color: ChartTheme.solarVoltage,
          ),
          LiveMetric(
            label: 'Output Voltage',
            value: latest.outputVoltage.toStringAsFixed(1),
            unit: 'V',
            icon: Icons.electrical_services,
            color: ChartTheme.outputVoltage,
          ),
          LiveMetric(
            label: 'Output Current',
            value: latest.outputCurrent.toStringAsFixed(1),
            unit: 'A',
            icon: Icons.electric_meter_outlined,
            color: ChartTheme.outputCurrent,
          ),
          // Grid telemetry only exists on newer firmware - stays the
          // disabled placeholder (never a fabricated value) for devices that
          // don't report it, and lights up live the moment they do.
          if (gridPowerKw == null)
            const LiveMetric(
              label: 'Grid Input',
              value: '--',
              unit: 'No data',
              icon: Icons.cell_tower,
              color: ChartTheme.labelMuted,
              disabled: true,
            )
          else
            LiveMetric(
              label: 'Grid Input',
              value: gridPowerKw.abs().toStringAsFixed(2),
              // Sign convention inferred from hardware sample physics (not
              // yet hardware-team-confirmed): positive = importing from the
              // grid, negative = exporting to it.
              unit: gridPowerKw >= 0 ? 'kW · Import' : 'kW · Export',
              icon: Icons.cell_tower,
              color: ChartTheme.indigo,
            ),
          // Same disabled/live pattern as Grid Input, driven by grid
          // voltage rather than grid power - PV Voltage and Output Voltage
          // both get their own tile, so Grid Voltage should too whenever a
          // device actually reports it.
          if (latest.gridVoltage == null)
            const LiveMetric(
              label: 'Grid Voltage',
              value: '--',
              unit: 'No data',
              icon: Icons.power_outlined,
              color: ChartTheme.labelMuted,
              disabled: true,
            )
          else
            LiveMetric(
              label: 'Grid Voltage',
              value: latest.gridVoltage!.toStringAsFixed(1),
              unit: 'V',
              icon: Icons.power_outlined,
              color: ChartTheme.indigo,
            ),
        ],
      ),
    );
  }
}

class _TodayProductionSection extends StatelessWidget {
  const _TodayProductionSection();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TodayProductionViewModel>();
    final lastReal = viewModel.lastRealBucketStart;
    final updatedAt =
        lastReal != null ? DateFormat('HH:mm').format(lastReal) : '--';

    return TodayProductionCard(
      todayEnergyKwh: viewModel.todayEnergyKwh,
      updatedAt: updatedAt,
      hourlySparkline: viewModel.hourlySparkline,
      todayGridImportKwh: viewModel.todayGridImportKwh,
    );
  }
}

/// Home's chart mode - deliberately just Today/Live. Day(any
/// date)/Week/Month/Year/Total live exclusively on the Analytics screen
/// (Statistic tab), so the two screens never show the same navigable chart
/// twice - Home is always pinned to "right now" (today, or live), nothing
/// to navigate.
enum _HomeChartMode { today, live }

class _CompactAnalyticsSection extends StatefulWidget {
  const _CompactAnalyticsSection();

  @override
  State<_CompactAnalyticsSection> createState() =>
      _CompactAnalyticsSectionState();
}

class _CompactAnalyticsSectionState extends State<_CompactAnalyticsSection> {
  _HomeChartMode _mode = _HomeChartMode.today;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Energy Analytics',
      icon: Icons.show_chart,
      accentColor: ChartTheme.brand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ModeToggle(
            mode: _mode,
            onChanged: (mode) => setState(() => _mode = mode),
          ),
          const SizedBox(height: 16),
          if (_mode == _HomeChartMode.live)
            const LiveEnergyChart()
          else
            _buildTodayChart(context),
        ],
      ),
    );
  }

  Widget _buildTodayChart(BuildContext context) {
    // Reuses TodayProductionViewModel's already-fetched hourly buckets (the
    // same data backing the sparkline above) instead of a separate
    // EnergyAnalyticsViewModel fetch - no extra network call, and Home's
    // "Today" never drifts out of sync with whatever period the Analytics
    // screen happens to be showing, since it doesn't share that state at all.
    final today = context.watch<TodayProductionViewModel>();
    if (today.isLoading && today.todayBuckets.isEmpty) {
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
    if (today.errorMessage != null && today.todayBuckets.isEmpty) {
      return const SizedBox(
        height: 200,
        child: ChartEmptyState(
          title: 'Could not load today\'s data',
          message: 'Check your connection and try again.',
          compact: true,
        ),
      );
    }
    if (today.todayBuckets.isEmpty) {
      return const SizedBox(
        height: 200,
        child: ChartEmptyState(
          title: 'No data for today',
          message: 'The inverter has not reported yet today.',
          compact: true,
        ),
      );
    }
    return PeriodMetricsCharts(
      buckets: today.todayBuckets,
      period: AnalyticsPeriod.day,
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final _HomeChartMode mode;
  final ValueChanged<_HomeChartMode> onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill('Today', _HomeChartMode.today),
        const SizedBox(width: 8),
        _pill('Live', _HomeChartMode.live),
      ],
    );
  }

  Widget _pill(String label, _HomeChartMode value) {
    final isActive = mode == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? ChartTheme.brand : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? ChartTheme.brand : ChartTheme.gridStrong,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : ChartTheme.label,
          ),
        ),
      ),
    );
  }
}

