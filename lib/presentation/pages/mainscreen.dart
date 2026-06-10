import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/data/models/DeviceModel.dart';
import 'package:threepol_inverter_flutter/data/models/inverter_data_model.dart';
import 'package:threepol_inverter_flutter/domain/entities/UserModel.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/HeaderWidget.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/WelcomeWidget.dart';

import '../../core/network/dio_client.dart';
import '../../data/repositories_impl/inverter_repository_impl.dart';
import '../../domain/usecases/get_inverter_data_usecase.dart';
import '../viewmodels/SelectedDeviceProvider.dart';
import '../viewmodels/inverter_viewmodel.dart';
import '../widgets/buildInverterCard.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> with WidgetsBindingObserver {
  // // @override
  // // void initState() {
  // //   super.initState();
  // //   WidgetsBinding.instance.addObserver(this);
  // //
  // //   // loadStoredDeviceData(); // NEW: Load stored name/mac/power
  // //
  // //   // final dioClient = DioClient();
  // //   // final repo = InverterRepositoryImpl(dioClient);
  // //   // final useCase = FetchInverterDataUseCase(repo);
  // //   // _vm = InverterViewModel(useCase);
  // //   Future.microtask(() {
  // //     //   _vm.fetchInverterData();
  // //     //   _vm.startAutoRefresh();
  // //     Provider.of<InverterViewModel>(context, listen: false)
  // //         .fetchInverterData();
  // //     Provider.of<InverterViewModel>(context, listen: false).startAutoRefresh();
  // //   });
  // // }
  // //
  // // @override
  // // void dispose() {
  // //   WidgetsBinding.instance.removeObserver(this);
  // //   try {
  // //     if (mounted) {
  // //       Provider.of<InverterViewModel>(context, listen: false)
  // //           .stopAutoRefresh();
  // //     }
  // //   } catch (e) {
  // //     debugPrint("Error stopping auto-refresh: $e");
  // //   }
  // //   super.dispose();
  // // }
  // //
  // // @override
  // // void didChangeAppLifecycleState(AppLifecycleState state) {
  // //   final inverterViewModel =
  // //       Provider.of<InverterViewModel>(context, listen: false);
  // //   if (state == AppLifecycleState.resumed) {
  // //     // Fluttertoast.showToast(msg: "onresume");
  // //     // print("resume");
  // //     inverterViewModel.startAutoRefresh(); // Restart when app is in foreground
  // //   } else if (state == AppLifecycleState.paused) {
  // //     // print("pause");
  // //     // Fluttertoast.showToast(msg: "onpause");
  // //     // inverterViewModel.stopAutoRefresh(); // Stop when app goes to background
  // //   }
  // // }
  //
  // late InverterViewModel viewModel;
  // @override
  // void initState() {
  //   super.initState();
  //
  //   final dioClient = DioClient();
  //   final repository = InverterRepositoryImpl(dioClient);
  //   final useCase = FetchInverterDataUseCase(repository);
  //   viewModel = InverterViewModel(useCase);
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     viewModel.fetchInverterData(); // call once on screen open
  //   });
  // }
  //
  // // @override
  // // void initState() {
  // //   super.initState();
  // //   WidgetsBinding.instance.addObserver(this);
  // //
  // //   // Initialize ViewModel directly here
  // //   final dioClient = DioClient();
  // //   final repo = InverterRepositoryImpl(dioClient);
  // //   final useCase = FetchInverterDataUseCase(repo);
  // //   _vm = InverterViewModel(useCase);
  // //
  // //   // Start fetching and auto-refreshing inverter data
  // //   Future.microtask(() async {
  // //     await _vm.fetchInverterData();
  // //     _vm.startAutoRefresh();
  // //   });
  // // }
  //
  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   viewModel.stopAutoRefresh();
  //   super.dispose();
  // }
  //
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     viewModel.startAutoRefresh();
  //   } else if (state == AppLifecycleState.paused) {
  //     viewModel.stopAutoRefresh();
  //   }
  // }
  late InverterViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    // Initialize ViewModel here
    final dioClient = DioClient();
    final repo = InverterRepositoryImpl(dioClient);
    final useCase = FetchInverterDataUseCase(repo);
    _viewModel = InverterViewModel(useCase);

    // Start fetching after first frame (to ensure context is ready)
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

                  // Consumer listens to ViewModel updates
                  ChangeNotifierProvider<InverterViewModel>.value(
                    value: _viewModel,
                    child: Consumer<InverterViewModel>(
                      builder: (context, viewModel, child) {
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
                        final inverterdata = InverterDataModel(
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
                            return buildInverterCard(
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
                            return buildInverterCard(
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

                        // final device = deviceviewModel.devices.isNotEmpty
                        //     ? deviceviewModel.devices.last
                        //     : deviceviewMo;
                        // final device = deviceviewModel.devices.last;

                        // for graph
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
                        return buildInverterCard(
                          dataoverall: dataoverall,
                          energydata: energydata,
                          endate: dategraph,
                          entime: timegraph,
                          data: data,
                          date: date,
                          time: time,
                          deviceName: deviceName,
                          // device: device,
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
  // @override
  // Widget build(BuildContext context) {
  //   // final deviceviewModel = Provider.of<DeviceViewModel>(context);
  //   return Scaffold(
  //     body: Stack(
  //       fit: StackFit.expand,
  //       children: [
  //         Image.asset("assets/bg.png", fit: BoxFit.cover),
  //         Container(color: Colors.black.withOpacity(0.1)),
  //         Padding(
  //           padding:
  //               const EdgeInsets.only(right: 15, left: 15, top: 10, bottom: 30),
  //           child: SingleChildScrollView(
  //             child: Column(
  //               children: [
  //                 const SizedBox(height: 35),
  //                 const HeaderWidget(),
  //                 const SizedBox(height: 20),
  //                 const WelcomeWidget(),
  //                 const SizedBox(height: 10),
  //                 Consumer<InverterViewModel>(
  //                   builder: (context, viewModel, child) {
  //                     final selectedDevice =
  //                         Provider.of<SelectedDeviceProvider>(context);
  //                     final _storedName = selectedDevice.name ?? "Unknown";
  //                     final _storedPower = selectedDevice.power ?? 0;
  //                     final deviceviewMo = DeviceModel(
  //                         id: 0,
  //                         macAddress: "",
  //                         invertername: "unknown",
  //                         inverterPower: 0,
  //                         user: UserModel(
  //                             id: 0,
  //                             username: "",
  //                             email: "",
  //                             address: "",
  //                             phone: ""));
  //                     final inverterdata = InverterDataModel(
  //                         id: 0,
  //                         energyConsumed: 00,
  //                         genPower: 00,
  //                         pvVoltage: 00,
  //                         outputVoltage: 00,
  //                         outputCurrent: 00,
  //                         macAddress: "",
  //                         error: 00,
  //                         deviceName: "",
  //                         version: "",
  //                         createdAt: DateTime.now());
  //                     if (viewModel.errorMessage != null) {
  //                       // return CardDesign(message: "No data available...");
  //
  //                       if (viewModel.errorMessage != null ||
  //                           viewModel.inverterData.isEmpty) {
  //                         return buildInverterCard(
  //                           dataoverall: [],
  //                           energydata: "N/A",
  //                           endate: "N/A",
  //                           entime: "N/A",
  //                           data: inverterdata,
  //                           date: "N/A",
  //                           time: "N/A",
  //                           deviceName: "N/A",
  //                           // device: deviceviewMo,
  //                           devicename: _storedName,
  //                           storedPower: _storedPower,
  //                         );
  //                       }
  //                     }
  //                     if (viewModel.inverterData.isEmpty) {
  //                       // return CardDesign(message: "No data available...");
  //                       if (viewModel.errorMessage != null ||
  //                           viewModel.inverterData.isEmpty) {
  //                         return buildInverterCard(
  //                           dataoverall: [],
  //                           energydata: "N/A",
  //                           endate: "N/A",
  //                           entime: "N/A",
  //                           data: inverterdata,
  //                           date: "N/A",
  //                           time: "N/A",
  //                           deviceName: "N/A",
  //                           // device: deviceviewMo,
  //                           devicename: _storedName,
  //                           storedPower: _storedPower,
  //                         );
  //                       }
  //                     }
  //                     final dataoverall = viewModel.inverterData;
  //                     final data = viewModel.inverterData.last;
  //                     String? timestamp = "${data.createdAt}" ?? "";
  //                     String date = "N/A", time = "N/A";
  //
  //                     if (timestamp.isNotEmpty) {
  //                       List<String> parts = timestamp.split(' ');
  //                       if (parts.length == 2) {
  //                         date = parts[0];
  //                         time = parts[1].split('.')[0];
  //                       }
  //                     }
  //
  //                     String original = data.deviceName ?? "Unknown";
  //                     List<String> parts = original.split('_');
  //                     String deviceName = parts.length > 1
  //                         ? parts.sublist(1).join('_')
  //                         : original;
  //
  //                     // final device = deviceviewModel.devices.isNotEmpty
  //                     //     ? deviceviewModel.devices.last
  //                     //     : deviceviewMo;
  //                     // final device = deviceviewModel.devices.last;
  //
  //                     // for graph
  //                     String dategraph = "N/A",
  //                         timegraph = "N/A",
  //                         energydata = "N/A",
  //                         timestamp1 = "N/A";
  //                     final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  //                     // final lastDate = dateFormat
  //                     //     .format(viewModel.inverterData.last.createdAt);
  //                     final lastDate = dataoverall.isNotEmpty
  //                         ? dateFormat.format(dataoverall.last.createdAt)
  //                         : "N/A";
  //
  //                     if (lastDate != "N/A") {
  //                       Set<String> uniqueEntries = {};
  //
  //                       final filteredData =
  //                           viewModel.inverterData.where((item) {
  //                         return dateFormat.format(item.createdAt) == lastDate;
  //                       }).toList();
  //
  //                       for (var item in filteredData) {
  //                         timestamp1 = DateFormat('yyyy-MM-dd HH:mm:ss')
  //                             .format(item.createdAt);
  //                         timegraph =
  //                             DateFormat('HH:mm:ss').format(item.createdAt);
  //                         dategraph =
  //                             DateFormat('yyyy-MM-dd').format(item.createdAt);
  //                         if (uniqueEntries.add(timestamp1)) {
  //                           energydata = "${item.energyConsumed}";
  //                         }
  //                       }
  //                     }
  //                     return buildInverterCard(
  //                       dataoverall: dataoverall,
  //                       energydata: energydata,
  //                       endate: dategraph,
  //                       entime: timegraph,
  //                       data: data,
  //                       date: date,
  //                       time: time,
  //                       deviceName: deviceName,
  //                       // device: device,
  //                       devicename: _storedName,
  //                       storedPower: _storedPower,
  //                     );
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
