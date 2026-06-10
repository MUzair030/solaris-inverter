import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/SelectedDeviceProvider.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/inverter_viewmodel.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/WelcomeWidget.dart';

import '../../../app/App_Colors.dart';
import '../../core/network/dio_client.dart';
import '../../data/repositories_impl/DeviceRepositoryImpl.dart';
import '../../data/repositories_impl/inverter_repository_impl.dart';
import '../../domain/usecases/FetchDevicesUseCase.dart';
import '../../domain/usecases/get_inverter_data_usecase.dart';
import '../viewmodels/DeviceViewModel.dart';
import '../viewmodels/inverter_viewmodel1.dart';
import '../widgets/DeviceCard.dart';
import '../widgets/HeaderWidget.dart';
import '../widgets/showExitConfirmationDialog.dart';

class Devicelistscreen extends StatefulWidget {
  const Devicelistscreen({super.key});

  @override
  State<Devicelistscreen> createState() => _DevicelistscreenState();
}

class _DevicelistscreenState extends State<Devicelistscreen> {
  late InverterViewModel inverterviewModel;
  late InverterViewModel1 inverterviewModel1;
  late SelectedDeviceProvider selectedprovider;
  @override
  void initState() {
    super.initState();

    // Future.microtask(() =>
    selectedprovider =
        Provider.of<SelectedDeviceProvider>(context, listen: false);

    // Initialize ViewModel here
    final dioClient = DioClient();
    final repo = InverterRepositoryImpl(dioClient);
    final useCase = FetchInverterDataUseCase(repo);
    inverterviewModel = InverterViewModel(useCase);

    // Initialize ViewModel here
    inverterviewModel1 = InverterViewModel1(useCase);

    // Start fetching after first frame (to ensure context is ready)
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _viewModel.setContext(context);
    //   _viewModel.fetchInverterData();
    //   _viewModel.startAutoRefresh();
    // });
  }

  @override
  void dispose() {
    inverterviewModel.stopAutoRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final inverterviewModel = Provider.of<InverterViewModel>(context);
    final dioClient = DioClient();
    final deviceRepository = DeviceRepositoryImpl(dioClient);
    final fetchDevicesUseCase = FetchDevicesUseCase(deviceRepository);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              DeviceViewModel(fetchDevicesUseCase: fetchDevicesUseCase)
                ..fetchDevices(),
        ),
        ChangeNotifierProvider.value(value: inverterviewModel),
        ChangeNotifierProvider.value(value: inverterviewModel1),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset("assets/bg.png", fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.1)),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 15, bottom: 80),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 35),
                    const HeaderWidget(),
                    const SizedBox(height: 20),
                    const WelcomeWidget(),
                    // Consumer listens to ViewModel updates
                    // ChangeNotifierProvider<InverterViewModel>.value(
                    //   value: inverterviewModel,
                    //   child:
                    Consumer2<DeviceViewModel, SelectedDeviceProvider>(
                      builder: (context, viewModel, selectedProvider, child) {
                        if (viewModel.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (viewModel.errorMessage != null) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const Center(
                              child: Text(
                                "No devices found.",
                                style: TextStyle(
                                    color: AppColors.white, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        } else if (viewModel.devices.isEmpty) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const Center(
                              child: Text(
                                "No devices found.",
                                style: TextStyle(
                                    color: AppColors.white, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        } else {
                          final dataList = inverterviewModel.inverterData;
                          final lastData =
                              dataList.isNotEmpty ? dataList.last : null;
                          String original = lastData?.deviceName ?? "Inverter";
                          List<String> parts = original.split('_');
                          String deviceName = parts.length > 1
                              ? parts.sublist(1).join('_')
                              : original;

                          return GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 1.05,
                            ),
                            itemCount: viewModel.devices.length,
                            itemBuilder: (context, index) {
                              final device = viewModel.devices[index];
                              final isSelected =
                                  selectedprovider.mac == device.macAddress;
                              return GestureDetector(
                                onTap: () async {
                                  if (!isSelected) {
                                    // await ExitConfirmationDialog
                                    //     .showConfirmationDialog(
                                    //   context,
                                    //   device.macAddress,
                                    //   device,
                                    // );
                                    await ExitConfirmationDialog
                                        .showConfirmationDialog(
                                            context,
                                            device.macAddress,
                                            device,
                                            inverterviewModel,
                                            inverterviewModel1);
                                  } else {
                                    await ExitConfirmationDialog
                                        .showDeleteDialog(
                                            context,
                                            device.macAddress,
                                            device,
                                            inverterviewModel1);
                                  }
                                },
                                child: DeviceCard(
                                  deviceName: deviceName,
                                  device: device,
                                  isSelected: isSelected,
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
