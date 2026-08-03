import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/network/dio_client.dart';
import '../../data/repositories_impl/inverter_repository_impl.dart';
import '../../domain/usecases/get_inverter_data_usecase.dart';
import '../../domain/utils/energy_math.dart';
import '../viewmodels/SelectedDeviceProvider.dart';
import '../viewmodels/inverter_viewmodel.dart';
import '../widgets/ChartEmptyState.dart';
import '../widgets/EnergyAnalyticsSection.dart';
import '../widgets/HeaderWidget.dart';
import '../widgets/LiveMetricsGrid.dart';
import '../widgets/PowerFlowDiagram.dart';
import '../widgets/TodayProductionCard.dart';
import '../widgets/WelcomeWidget.dart';
import '../../app/chart_theme.dart';

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

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2130),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 2),
        ],
      ),
      child: child,
    );
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
            padding: const EdgeInsets.only(right: 15, left: 15, top: 10, bottom: 30),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 35),
                  const HeaderWidget(),
                  const SizedBox(height: 20),
                  const WelcomeWidget(),
                  const SizedBox(height: 16),
                  ChangeNotifierProvider<InverterViewModel>.value(
                    value: _viewModel,
                    child: Consumer<InverterViewModel>(
                      builder: (context, viewModel, child) {
                        final selectedDevice =
                            Provider.of<SelectedDeviceProvider>(context);
                        final data = viewModel.inverterData;

                        if (data.isEmpty) {
                          return _card(
                            SizedBox(
                              height: 260,
                              child: ChartEmptyState(
                                title: 'Waiting for live data',
                                message: viewModel.errorMessage ??
                                    'Live values and power flow will appear once the inverter reports.',
                              ),
                            ),
                          );
                        }

                        final live = data.last;
                        final loadKw = live.outputVoltage * live.outputCurrent / 1000;
                        final todayKwh = energyTodayKwh(data, DateTime.now());
                        final devicePowerKw = (selectedDevice.power ?? 0) / 1000.0;
                        final flowNorm = devicePowerKw > 0
                            ? (live.genPower / devicePowerKw).clamp(0.0, 1.0)
                            : (live.genPower > 0 ? 0.5 : 0.0);
                        final updatedAt =
                            DateFormat('HH:mm').format(live.createdAt);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _card(
                              PowerFlowDiagram(
                                genPowerKw: live.genPower,
                                loadKw: loadKw,
                                pvVoltage: live.pvVoltage,
                                outputVoltage: live.outputVoltage,
                                outputCurrent: live.outputCurrent,
                                flow: flowNorm.toDouble(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            LiveMetricsGrid(
                              metrics: [
                                LiveMetric(
                                  label: 'Solar Generation',
                                  value: live.genPower.toStringAsFixed(2),
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
                                  label: 'Output Voltage',
                                  value: live.outputVoltage.toStringAsFixed(0),
                                  unit: 'V',
                                  icon: Icons.electrical_services,
                                  color: ChartTheme.outputVoltage,
                                ),
                                LiveMetric(
                                  label: 'Output Current',
                                  value: live.outputCurrent.toStringAsFixed(1),
                                  unit: 'A',
                                  icon: Icons.bolt_outlined,
                                  color: ChartTheme.outputCurrent,
                                ),
                                LiveMetric(
                                  label: 'PV Voltage',
                                  value: live.pvVoltage.toStringAsFixed(0),
                                  unit: 'V',
                                  icon: Icons.solar_power_outlined,
                                  color: ChartTheme.solarVoltage,
                                ),
                                LiveMetric(
                                  label: 'Energy Today',
                                  value: todayKwh.toStringAsFixed(2),
                                  unit: 'kWh',
                                  icon: Icons.savings,
                                  color: ChartTheme.brand,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TodayProductionCard(
                              todayEnergyKwh: todayKwh,
                              capacityKwh: devicePowerKw > 0 ? devicePowerKw * 8 : null,
                              updatedAt: updatedAt,
                            ),
                            const SizedBox(height: 16),
                            EnergyAnalyticsSection(
                              macAddress: selectedDevice.mac,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
