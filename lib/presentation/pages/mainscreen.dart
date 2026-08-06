import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/App_Colors.dart';
import '../../app/chart_theme.dart';
import '../../core/network/dio_client.dart';
import '../../data/repositories_impl/inverter_repository_impl.dart';
import '../../domain/usecases/get_inverter_data_usecase.dart';
import '../../domain/utils/energy_math.dart';
import '../viewmodels/SelectedDeviceProvider.dart';
import '../viewmodels/energy_analytics_viewmodel.dart';
import '../viewmodels/inverter_viewmodel.dart';
import '../viewmodels/live_inverter_viewmodel.dart';
import '../widgets/AnalyticsPeriodSelector.dart';
import '../widgets/ChartEmptyState.dart';
import '../widgets/HeaderWidget.dart';
import '../widgets/LiveEnergyChart.dart';
import '../widgets/LiveMetricsGrid.dart';
import '../widgets/PeriodMetricsCharts.dart';
import '../widgets/PowerFlowDiagram.dart';
import '../widgets/SectionCard.dart';
import '../widgets/TodayProductionCard.dart';
import '../widgets/WelcomeWidget.dart';

/// Dashboard: power-flow diagram -> live metrics grid -> today's production
/// -> compact energy analytics, fed by the shared [LiveInverterViewModel] and
/// [EnergyAnalyticsViewModel] instances owned by the tab shell
/// (`Mainbottomnavigationview`), plus a dashboard-local [InverterViewModel]
/// used only to source "today's" raw readings for the production card.
class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  late InverterViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    final dioClient = DioClient();
    final repo = InverterRepositoryImpl(dioClient);
    final useCase = FetchInverterDataUseCase(repo);
    _viewModel = InverterViewModel(useCase);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.setContext(context);
      _viewModel.fetchInverterData();
      _viewModel.startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _viewModel.stopAutoRefresh();
    super.dispose();
  }

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
                  ChangeNotifierProvider<InverterViewModel>.value(
                    value: _viewModel,
                    child: const _TodayProductionSection(),
                  ),
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

    final genPowerKw = latest.genPower;
    final loadKw = latest.outputVoltage * latest.outputCurrent / 1000.0;
    double flow = 0.4;
    if (devicePower != null && devicePower > 0) {
      flow = (genPowerKw * 1000 / devicePower).clamp(0.0, 1.0);
    }

    return SectionCard(
      title: 'Live Power Flow',
      icon: Icons.bolt,
      accentColor: ChartTheme.brand,
      child: PowerFlowDiagram(
        genPowerKw: genPowerKw,
        loadKw: loadKw,
        pvVoltage: latest.pvVoltage,
        outputVoltage: latest.outputVoltage,
        outputCurrent: latest.outputCurrent,
        flow: flow,
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

    final loadKw = latest.outputVoltage * latest.outputCurrent / 1000.0;

    return SectionCard(
      title: 'Live Metrics',
      icon: Icons.dashboard_outlined,
      accentColor: ChartTheme.cyan,
      child: LiveMetricsGrid(
        metrics: [
          LiveMetric(
            label: 'Solar Generation',
            value: latest.genPower.toStringAsFixed(2),
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
        ],
      ),
    );
  }
}

class _TodayProductionSection extends StatelessWidget {
  const _TodayProductionSection();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InverterViewModel>();
    final now = DateTime.now();
    final data = viewModel.inverterData;

    final todayEnergyKwh = energyTodayKwh(data, now);
    final hourly = hourlyEnergyDeltasToday(data, now);
    final updatedAt = data.isNotEmpty
        ? DateFormat('HH:mm').format(data.last.createdAt)
        : '--';

    return TodayProductionCard(
      todayEnergyKwh: todayEnergyKwh,
      updatedAt: updatedAt,
      hourlySparkline: hourly,
    );
  }
}

class _CompactAnalyticsSection extends StatelessWidget {
  const _CompactAnalyticsSection();

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<EnergyAnalyticsViewModel>();

    return SectionCard(
      title: 'Energy Analytics',
      icon: Icons.show_chart,
      accentColor: ChartTheme.brand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AnalyticsPeriodSelector(),
          const SizedBox(height: 16),
          if (analytics.period == AnalyticsPeriod.live)
            const LiveEnergyChart()
          else if (analytics.period == AnalyticsPeriod.total)
            _LifetimeSummary(analytics: analytics)
          else
            _buildChart(analytics),
        ],
      ),
    );
  }

  Widget _buildChart(EnergyAnalyticsViewModel analytics) {
    if (analytics.isLoading && analytics.buckets.isEmpty) {
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
    if (analytics.errorMessage != null && analytics.buckets.isEmpty) {
      return const SizedBox(
        height: 200,
        child: ChartEmptyState(
          title: 'Could not load analytics',
          message: 'Check your connection and try again.',
          compact: true,
        ),
      );
    }
    if (analytics.buckets.isEmpty) {
      return const SizedBox(
        height: 200,
        child: ChartEmptyState(
          title: 'No data for this range',
          message: 'The inverter has not reported in this period.',
          compact: true,
        ),
      );
    }
    return PeriodMetricsCharts(
      buckets: analytics.buckets,
      period: analytics.period,
    );
  }
}

/// Compact lifetime total shown for [AnalyticsPeriod.total] instead of a
/// chart — the backend returns one (already-correct, un-padded) bucket per
/// calendar year, so summing those per-year deltas is a valid lifetime total
/// (never a sum of raw cumulative meter readings).
class _LifetimeSummary extends StatelessWidget {
  final EnergyAnalyticsViewModel analytics;

  const _LifetimeSummary({required this.analytics});

  @override
  Widget build(BuildContext context) {
    if (analytics.isLoading && analytics.buckets.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: ChartTheme.brand,
          ),
        ),
      );
    }
    if (analytics.buckets.isEmpty) {
      return const SizedBox(
        height: 120,
        child: ChartEmptyState(
          title: 'No lifetime data yet',
          compact: true,
        ),
      );
    }

    final total =
        analytics.buckets.fold<double>(0.0, (sum, b) => sum + b.energyDeltaKwh);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LIFETIME ENERGY PRODUCED',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.2,
            color: ChartTheme.labelMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              total.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 6, bottom: 4),
              child: Text(
                'kWh',
                style: TextStyle(
                  fontSize: 13,
                  color: ChartTheme.brand,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final bucket in analytics.buckets)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${bucket.bucket}: ${bucket.energyDeltaKwh.toStringAsFixed(1)} kWh',
                  style: const TextStyle(fontSize: 11, color: ChartTheme.label),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
