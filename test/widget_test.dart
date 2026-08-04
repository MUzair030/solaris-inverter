// Basic widget tests for the modernized / new chart widgets.
//
// These tests are hermetic: they pump the chart widgets with sample data and
// need no platform plugins, so they run safely on any host.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:threepol_inverter_flutter/app/chart_theme.dart';
import 'package:threepol_inverter_flutter/data/models/inverter_data_model.dart';
import 'package:threepol_inverter_flutter/domain/utils/energy_math.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/ChartEmptyState.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/EnergyDonutChart.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/LiveMetricsGrid.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/MetricBarChart.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/MetricRadarChart.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/PowerFlowDiagram.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/PowerGaugeWidget.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/ScatterCorrelationChart.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/TodayProductionCard.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/ZoomableLineChart.dart';

void main() {
  testWidgets('ChartEmptyState shows title and message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChartEmptyState(
            title: 'No data available',
            message: 'Telemetry will appear here.',
          ),
        ),
      ),
    );
    expect(find.text('No data available'), findsOneWidget);
    expect(find.text('Telemetry will appear here.'), findsOneWidget);
  });

  testWidgets('PowerGaugeWidget shows value and unit', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 280,
            height: 280,
            child: PowerGaugeWidget(
              value: 2.5,
              max: 5.0,
              unit: 'kW',
              title: 'Generation Power',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('2.50'), findsOneWidget);
    expect(find.text('kW'), findsOneWidget);
  });

  testWidgets('EnergyDonutChart renders legend shares', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnergyDonutChart(
            segments: const [
              DonutSegment(label: 'Morning', value: 20, color: ChartTheme.brand),
              DonutSegment(label: 'Night', value: 80, color: ChartTheme.indigo),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Morning'), findsWidgets);
    expect(find.textContaining('Night'), findsWidgets);
    expect(find.textContaining('100%'), findsNothing);
    expect(find.textContaining('20%'), findsWidgets);
  });

  testWidgets('EnergyDonutChart handles zero total with empty state',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnergyDonutChart(
            segments: const [
              DonutSegment(label: 'Morning', value: 0, color: ChartTheme.brand),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No energy data'), findsOneWidget);
  });

  testWidgets('MetricBarChart renders horizontal rods with labels',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MetricBarChart(
            items: const [
              MetricBarItem(
                label: 'Generation Power',
                value: 4.2,
                unit: 'kW',
                color: ChartTheme.power,
              ),
              MetricBarItem(
                label: 'Output Voltage',
                value: 230,
                unit: 'V',
                color: ChartTheme.outputVoltage,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BarChart), findsOneWidget);
  });

  testWidgets('MetricRadarChart renders when at least 3 metrics are given',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 260,
            child: MetricRadarChart(
              metrics: [
                RadarMetric(label: 'Power', value: 4, max: 5),
                RadarMetric(label: 'PV V', value: 120, max: 200),
                RadarMetric(label: 'Out A', value: 8, max: 10),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(RadarChart), findsOneWidget);
  });

  testWidgets('MetricRadarChart shows empty state with fewer than 3 metrics',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetricRadarChart(metrics: [RadarMetric(label: 'P', value: 1, max: 2)]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Not enough dimensions'), findsOneWidget);
  });

  testWidgets('ScatterCorrelationChart renders points', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScatterCorrelationChart(
            points: const [
              ScatterPoint(x: 230, y: 5, label: '230 V · 5 A'),
              ScatterPoint(x: 231, y: 6, label: '231 V · 6 A'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ScatterChart), findsOneWidget);
  });

  test('ChartTheme.formatCompact formats large values', () {
    expect(ChartTheme.formatCompact(999), '999');
    expect(ChartTheme.formatCompact(1234), '1.2k');
    expect(ChartTheme.formatCompact(1234567), '1.2M');
    expect(ChartTheme.formatCompact(12.34), '12.3');
  });

  testWidgets('PowerFlowDiagram shows node values', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PowerFlowDiagram(
            genPowerKw: 3.2,
            loadKw: 2.1,
            pvVoltage: 118.5,
            outputVoltage: 230,
            outputCurrent: 9.2,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Solar'), findsOneWidget);
    expect(find.text('Inverter'), findsOneWidget);
    expect(find.text('House'), findsOneWidget);
    expect(find.text('3.20 kW'), findsOneWidget);
  });

  testWidgets('LiveMetricsGrid renders each metric value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiveMetricsGrid(
            metrics: const [
              LiveMetric(
                label: 'Solar Generation',
                value: '3.20',
                unit: 'kW',
                icon: Icons.solar_power,
                color: ChartTheme.power,
              ),
              LiveMetric(
                label: 'House Load',
                value: '2.10',
                unit: 'kW',
                icon: Icons.home,
                color: ChartTheme.cyan,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Solar Generation'), findsOneWidget);
    expect(find.text('3.20'), findsOneWidget);
    expect(find.text('House Load'), findsOneWidget);
  });

  testWidgets('TodayProductionCard shows today energy and progress',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TodayProductionCard(
            todayEnergyKwh: 12.3,
            updatedAt: '14:05',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('12.30'), findsOneWidget);
    expect(find.text('kWh'), findsOneWidget);
    expect(find.textContaining('TODAY'), findsOneWidget);
  });

  testWidgets('ZoomableLineChart renders line spots', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 220,
            child: ZoomableLineChart(
              spots: const [
                FlSpot(0, 2),
                FlSpot(1, 3),
                FlSpot(2, 4),
                FlSpot(3, 5),
              ],
              labels: const ['0', '1', '2', '3'],
              color: ChartTheme.brand,
              unit: 'kWh',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LineChart), findsOneWidget);
  });

  testWidgets('ZoomableLineChart shows empty state without spots',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 220,
            child: ZoomableLineChart(
              spots: const [],
              labels: const [],
              color: ChartTheme.brand,
              unit: 'kWh',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No data available'), findsOneWidget);
  });

  test('energyTodayKwh uses delta of the day, not sum', () {
    final now = DateTime(2026, 8, 3, 14, 0);
    InverterDataModel row(double energy, DateTime at) => InverterDataModel(
          id: 1,
          energyConsumed: energy,
          genPower: 2.0,
          pvVoltage: 120,
          outputVoltage: 230,
          outputCurrent: 8,
          macAddress: 'AA:BB',
          error: 0,
          deviceName: 'v1',
          version: 'VER_3',
          createdAt: at,
        );

    expect(energyTodayKwh(const [], now), 0.0);

    // One reading today -> not enough to compute a delta.
    expect(
      energyTodayKwh(
        [row(8945.82, DateTime(2026, 8, 3, 9, 0))],
        now,
      ),
      0.0,
    );

    // Two readings today -> delta (this is what was producing 8945 before).
    expect(
      energyTodayKwh(
        [
          row(8900.0, DateTime(2026, 8, 3, 0, 30)),
          row(8945.82, DateTime(2026, 8, 3, 14, 0)),
        ],
        now,
      ),
      closeTo(45.82, 1e-6),
    );

    // Yesterday's readings are excluded.
    expect(
      energyTodayKwh(
        [
          row(8000.0, DateTime(2026, 8, 2, 23, 59)),
          row(8900.0, DateTime(2026, 8, 3, 0, 30)),
          row(8945.82, DateTime(2026, 8, 3, 14, 0)),
        ],
        now,
      ),
      closeTo(45.82, 1e-6),
    );

    // Counter rollover / reset must not produce negative energy.
    expect(
      energyTodayKwh(
        [
          row(8945.82, DateTime(2026, 8, 3, 0, 30)),
          row(12.4, DateTime(2026, 8, 3, 14, 0)),
        ],
        now,
      ),
      0.0,
    );
  });
}
