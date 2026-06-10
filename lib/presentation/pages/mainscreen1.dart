import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/network/dio_client.dart';
import '../../data/models/DeviceModel.dart';
import '../../data/models/geyser_history_response_model.dart';
import '../../data/repositories_impl/geyser_history_repository_impl.dart';
import '../../domain/entities/UserModel.dart';
import '../../domain/entities/geyser_history_data_entity.dart';
import '../../domain/usecases/fetch_geyser_history_data_usecase.dart';
import '../viewmodels/SelectedDeviceProvider.dart';
import '../viewmodels/geyser_history_viewmodel.dart';
import '../widgets/HeaderWidget.dart';
import '../widgets/WelcomeWidget.dart';
import '../widgets/buildHistoryInverterCard.dart';

class MainScreen1 extends StatefulWidget {
  const MainScreen1({super.key});

  @override
  State<MainScreen1> createState() => _MainScreen1State();
}

class _MainScreen1State extends State<MainScreen1> with WidgetsBindingObserver {
  late GeyserHistoryViewModel viewModel;

  @override
  void initState() {
    super.initState();

    final dioClient = DioClient();
    final repository = GeyserHistoryRepositoryImpl(dioClient);
    final useCase = FetchGeyserHistoryDataUseCase(repository);
    viewModel = GeyserHistoryViewModel(useCase);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchInverterData(); // call once on screen open
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image.asset("assets/bg.png", fit: BoxFit.cover),
          // Container(color: Colors.black.withOpacity(0.1)),
          Padding(
            padding:
                const EdgeInsets.only(right: 15, left: 15, top: 10, bottom: 30),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 35),
                  const HeaderWidget(),
                  const SizedBox(height: 20),
                  const WelcomeWidget(),
                  const SizedBox(height: 10),
                  ChangeNotifierProvider(
                    create: (_) => viewModel,
                    child: Consumer<GeyserHistoryViewModel>(
                      builder: (context, vm, _) {
                        final selectedDevice =
                            Provider.of<SelectedDeviceProvider>(context);
                        final _storedName = selectedDevice.name ?? "Unknown";
                        final _storedPower = selectedDevice.power ?? 0;
                        final deviceviewMo = DeviceModel(
                            id: 0,
                            macAddress: "",
                            invertername: "unknown",
                            inverterPower: 0,
                            user: UserModel(
                                id: 0,
                                username: "",
                                email: "",
                                address: "",
                                phone: ""));
                        final inverterdata = GeyserHistoryResponseModel(
                            id: 0,
                            energyConsumed: 00,
                            genPower: 00,
                            pvVoltage: 00,
                            outputVoltage: 00,
                            outputCurrent: 00,
                            macAddress: "",
                            error: 00,
                            deviceName: "",
                            version: "",
                            createdAt: DateTime.now());
                        if (viewModel.errorMessage != null) {
                          // return CardDesign(message: "No data available...");

                          if (viewModel.errorMessage != null ||
                              viewModel.inverterData.isEmpty) {
                            return buildHistoryInverterCard(
                              dataoverall: [],
                              energydata: "N/A",
                              endate: "N/A",
                              entime: "N/A",
                              data: inverterdata,
                              date: "N/A",
                              time: "N/A",
                              deviceName: "N/A",
                              // device: deviceviewMo,
                              devicename: _storedName,
                              storedPower: _storedPower,
                            );
                          }
                        }
                        if (viewModel.inverterData.isEmpty) {
                          // return CardDesign(message: "No data available...");
                          if (viewModel.errorMessage != null ||
                              viewModel.inverterData.isEmpty) {
                            return buildHistoryInverterCard(
                              dataoverall: [],
                              energydata: "N/A",
                              endate: "N/A",
                              entime: "N/A",
                              data: inverterdata,
                              date: "N/A",
                              time: "N/A",
                              deviceName: "N/A",
                              // device: deviceviewMo,
                              devicename: _storedName,
                              storedPower: _storedPower,
                            );
                          }
                        }
                        final dataoverall = viewModel.inverterData;
                        final data = viewModel.inverterData.last;
                        String? timestamp = "${data.createdAt}" ?? "";
                        String date = "N/A", time = "N/A";

                        if (timestamp.isNotEmpty) {
                          List<String> parts = timestamp.split(' ');
                          if (parts.length == 2) {
                            date = parts[0];
                            time = parts[1].split('.')[0];
                          }
                        }

                        String original = data.deviceName ?? "Unknown";
                        List<String> parts = original.split('_');
                        String deviceName = parts.length > 1
                            ? parts.sublist(1).join('_')
                            : original;

                        String dategraph = "N/A",
                            timegraph = "N/A",
                            energydata = "N/A",
                            timestamp1 = "N/A";
                        final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
                        // final lastDate = dateFormat
                        //     .format(viewModel.inverterData.last.createdAt);
                        final lastDate = dataoverall.isNotEmpty
                            ? dateFormat.format(dataoverall.last.createdAt)
                            : "N/A";

                        if (lastDate != "N/A") {
                          Set<String> uniqueEntries = {};

                          final filteredData =
                              viewModel.inverterData.where((item) {
                            return dateFormat.format(item.createdAt) ==
                                lastDate;
                          }).toList();

                          for (var item in filteredData) {
                            timestamp1 = DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(item.createdAt);
                            timegraph =
                                DateFormat('HH:mm:ss').format(item.createdAt);
                            dategraph =
                                DateFormat('yyyy-MM-dd').format(item.createdAt);
                            if (uniqueEntries.add(timestamp1)) {
                              energydata = "${item.energyConsumed}";
                            }
                          }
                        }

                        final latest = vm.latestData;

                        return buildHistoryInverterCard(
                          dataoverall: dataoverall,
                          energydata: energydata,
                          endate: dategraph,
                          entime: timegraph,
                          data: data,
                          date: date,
                          time: time,
                          deviceName: deviceName,
                          devicename: _storedName,
                          storedPower: _storedPower,
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
