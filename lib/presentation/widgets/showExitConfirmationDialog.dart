import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/app/App_Colors.dart';
import 'package:threepol_inverter_flutter/presentation/pages/mainscreen.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/inverter_viewmodel.dart';
import 'package:threepol_inverter_flutter/utils/SharedPreferencesHelper.dart';

import '../../data/models/DeviceModel.dart';
import '../viewmodels/DeleteDeviceViewModel.dart';
import '../viewmodels/DeviceViewModel.dart';
import '../viewmodels/SelectedDeviceProvider.dart';
import '../viewmodels/inverter_viewmodel1.dart';
import 'CustomInkWellItem1.dart';
import 'CustomInkWellItem2.dart';
import 'CustomInkWellItem3.dart';

class ExitConfirmationDialog {
  static Future<bool> showExitConfirmationDialog(BuildContext context) async {
    bool? shouldExit = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Exit App",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Do you really want to exit the app?",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2277BB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text(
                        "Exit",
                        style: TextStyle(color: AppColors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    return shouldExit ?? false; // default to false if user dismisses
  }

  // static Future<bool> showConfirmationDialog(
  //   BuildContext context,
  //   String macAddress,
  //   DeviceModel device,
  //   InverterViewModel inverterViewModel,
  //   InverterViewModel1 inverterModel1,
  // ) async {
  //   final deleteViewModel =
  //       Provider.of<DeleteDeviceViewModel>(context, listen: false);
  //   final deviceViewModel =
  //       Provider.of<DeviceViewModel>(context, listen: false);
  //   final selectedProvider =
  //       Provider.of<SelectedDeviceProvider>(context, listen: false);
  //
  //   bool isLoading = false;
  //
  //   return await showModalBottomSheet<bool>(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     backgroundColor: Colors.white,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return Padding(
  //             padding: const EdgeInsets.all(0),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Stack(
  //                   children: [
  //                     Center(
  //                       child: Padding(
  //                         padding: const EdgeInsets.only(top: 10),
  //                         child: Image.asset(
  //                           "assets/inverter1.png",
  //                           height: 70,
  //                           width: 70,
  //                         ),
  //                       ),
  //                     ),
  //                     Align(
  //                       alignment: Alignment.topRight,
  //                       child: IconButton(
  //                         icon: const Icon(Icons.close,
  //                             size: 27, color: AppColors.green),
  //                         onPressed: () => Navigator.of(context).pop(false),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 Padding(
  //                   padding:
  //                       const EdgeInsets.only(left: 20, right: 20, bottom: 10),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     children: [
  //                       Text(
  //                         device.invertername ?? "Unknown Device",
  //                         style: const TextStyle(
  //                             fontSize: 20, fontWeight: FontWeight.w600),
  //                       ),
  //                       const SizedBox(height: 10),
  //                       const Text(
  //                         "Do you want to Select or Delete this Inverter?",
  //                         textAlign: TextAlign.center,
  //                         style: TextStyle(fontSize: 16),
  //                       ),
  //                       const SizedBox(height: 16),
  //                       if (isLoading)
  //                         const Center(child: CircularProgressIndicator()),
  //                       const SizedBox(height: 20),
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                         children: [
  //                           Expanded(
  //                             child: OutlinedButton(
  //                               style: OutlinedButton.styleFrom(
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(10),
  //                                 ),
  //                               ),
  //                               onPressed: () async {
  //                                 setState(() => isLoading = true);
  //
  //                                 // Delete device
  //                                 await deleteViewModel.deleteDevice(device.id);
  //
  //                                 setState(() => isLoading = false);
  //
  //                                 if (deleteViewModel.response != null) {
  //                                   Fluttertoast.showToast(
  //                                     msg: deleteViewModel.response!.message,
  //                                     backgroundColor: const Color(0xFF2277BB),
  //                                   );
  //
  //                                   await deviceViewModel.fetchDevices();
  //
  //                                   // Clear selected if it was the deleted device
  //                                   if (selectedProvider.mac ==
  //                                       device.macAddress) {
  //                                     await SharedPreferencesHelper
  //                                         .clearMacData();
  //                                     selectedProvider.clearDevice();
  //                                   }
  //
  //                                   Navigator.of(context).pop(true);
  //                                 } else {
  //                                   Fluttertoast.showToast(
  //                                     msg: deleteViewModel.error ??
  //                                         "Failed to delete",
  //                                     backgroundColor: Colors.red,
  //                                   );
  //                                 }
  //                               },
  //                               child: const Text("Delete"),
  //                             ),
  //                           ),
  //                           const SizedBox(width: 15),
  //                           Expanded(
  //                             child: ElevatedButton(
  //                               style: ElevatedButton.styleFrom(
  //                                 backgroundColor: AppColors.green,
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(10),
  //                                 ),
  //                               ),
  //                               onPressed: () async {
  //                                 setState(() => isLoading = true);
  //
  //                                 // Save selected device immediately
  //                                 await SharedPreferencesHelper.saveMacData(
  //                                     macAddress,
  //                                     device.invertername!,
  //                                     device.inverterPower);
  //
  //                                 selectedProvider.setDevice(
  //                                     macAddress,
  //                                     device.invertername!,
  //                                     device.inverterPower);
  //
  //                                 // Fetch inverter data asynchronously
  //                                 inverterViewModel.fetchInverterData();
  //                                 inverterViewModel.startAutoRefresh();
  //                                 inverterModel1.fetchInverterData("daily",
  //                                     macAddress: macAddress);
  //                                 inverterModel1.fetchInverterData("weekly",
  //                                     macAddress: macAddress);
  //                                 inverterModel1.fetchInverterData("monthly",
  //                                     macAddress: macAddress);
  //                                 inverterModel1.fetchInverterData("yearly",
  //                                     macAddress: macAddress);
  //
  //                                 setState(() => isLoading = false);
  //                                 Navigator.of(context).pop(true);
  //                               },
  //                               child: const Text(
  //                                 "Select",
  //                                 style: TextStyle(color: AppColors.black),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(height: 10),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   ).then((value) => value ?? false);
  // }

  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String macaddress,
    DeviceModel device,
    InverterViewModel inverterViewModel,
    InverterViewModel1 inverterViewModel1,
  ) async {
    final deleteViewModel =
        Provider.of<DeleteDeviceViewModel>(context, listen: false);
    final deviceViewModel =
        Provider.of<DeviceViewModel>(context, listen: false);

    bool isLoading = false;

    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Image.asset(
                            "assets/inverter1.png",
                            height: 70,
                            width: 70,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(Icons.close,
                                size: 27, color: AppColors.green),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            device.invertername ?? "Unknown Device",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Do you want to Select or Delete this Inverter?",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        if (isLoading)
                          const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() => isLoading = true);

                                  await deleteViewModel.deleteDevice(device.id);

                                  setState(() => isLoading = false);

                                  final selectedProvider =
                                      Provider.of<SelectedDeviceProvider>(
                                          context,
                                          listen: false);

                                  if (deleteViewModel.response != null) {
                                    Fluttertoast.showToast(
                                      msg: deleteViewModel.response!.message,
                                      backgroundColor: const Color(0xFF2277BB),
                                    );

                                    await deviceViewModel.fetchDevices();

                                    if (selectedProvider.mac ==
                                        device.macAddress) {
                                      await SharedPreferencesHelper
                                          .clearMacData();
                                      selectedProvider.clearDevice();
                                    }

                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      Navigator.of(context).pop(true);
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: deleteViewModel.error ??
                                          "Failed to delete",
                                      backgroundColor: Colors.red,
                                    );
                                  }
                                },
                                child: const Text("Delete"),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() => isLoading = true);

                                  final selectedProvider =
                                      Provider.of<SelectedDeviceProvider>(
                                          context,
                                          listen: false);
                                  // final inverterViewModel =
                                  //     Provider.of<InverterViewModel>(context,
                                  //         listen: false);
                                  // final inverterModel1 =
                                  //     Provider.of<InverterViewModel1>(context,
                                  //         listen: false);

                                  await Future.wait([
                                    SharedPreferencesHelper.saveMacData(
                                        macaddress,
                                        device.invertername!,
                                        device.inverterPower),
                                    inverterViewModel.fetchInverterData(),
                                    inverterViewModel.startAutoRefresh(),
                                    inverterViewModel1.fetchInverterData(
                                        "daily",
                                        macAddress: macaddress),
                                    inverterViewModel1.fetchInverterData(
                                        "weekly",
                                        macAddress: macaddress),
                                    inverterViewModel1.fetchInverterData(
                                        "monthly",
                                        macAddress: macaddress),
                                    inverterViewModel1.fetchInverterData(
                                        "yearly",
                                        macAddress: macaddress),
                                  ]);

                                  selectedProvider.setDevice(
                                    macaddress,
                                    device.invertername!,
                                    device.inverterPower,
                                  );

                                  setState(() => isLoading = false);
                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    Navigator.of(context).pop(true);
                                  });
                                },
                                child: const Text(
                                  "Select",
                                  style: TextStyle(color: AppColors.black),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((value) => value ?? false);
  }

  static Future<bool> showDeleteDialog(
    BuildContext context,
    String macaddress,
    DeviceModel device,
    InverterViewModel1 inverterViewModel1,
  ) async {
    final deleteViewModel =
        Provider.of<DeleteDeviceViewModel>(context, listen: false);
    final deviceViewModel =
        Provider.of<DeviceViewModel>(context, listen: false);

    bool isLoading = false;

    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Image.asset(
                            "assets/inverter1.png",
                            height: 70,
                            width: 70,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(Icons.close,
                                size: 27, color: AppColors.green),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            device.invertername ?? "Unknown Device",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Do you want to Select or Delete this Inverter?",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        if (isLoading)
                          const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() => isLoading = true);

                                  await deleteViewModel.deleteDevice(device.id);

                                  setState(() => isLoading = false);

                                  final selectedProvider =
                                      Provider.of<SelectedDeviceProvider>(
                                          context,
                                          listen: false);

                                  if (deleteViewModel.response != null) {
                                    Fluttertoast.showToast(
                                      msg: deleteViewModel.response!.message,
                                      backgroundColor: const Color(0xFF2277BB),
                                    );

                                    await deviceViewModel.fetchDevices();

                                    if (selectedProvider.mac ==
                                        device.macAddress) {
                                      await SharedPreferencesHelper
                                          .clearMacData();
                                      selectedProvider.clearDevice();
                                    }

                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      Navigator.of(context).pop(true);
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: deleteViewModel.error ??
                                          "Failed to delete",
                                      backgroundColor: Colors.red,
                                    );
                                  }
                                },
                                child: const Text("Delete"),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() => isLoading = true);

                                  // await deleteViewModel.deleteDevice(device.id);

                                  setState(() => isLoading = false);

                                  final selectedProvider =
                                      Provider.of<SelectedDeviceProvider>(
                                          context,
                                          listen: false);

                                  // if (deleteViewModel.response != null) {
                                  Fluttertoast.showToast(
                                    msg: "Device Unselected",
                                    backgroundColor: const Color(0xFF2277BB),
                                  );
                                  // Provider.of<InverterViewModel1>(context,
                                  //         listen: false)
                                  inverterViewModel1.setSelectedMac(null);

                                  if (selectedProvider.mac ==
                                      device.macAddress) {
                                    await SharedPreferencesHelper
                                        .clearMacData();
                                    selectedProvider.clearDevice();
                                  }

                                  // String? getmac = await SharedPreferencesHelper
                                  //     .getMacData();
                                  //
                                  // Fluttertoast.showToast(
                                  //     msg: "getfinalmac:$getmac");

                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    Navigator.of(context).pop(true);
                                  });
                                  // }
                                  // else {
                                  //   Fluttertoast.showToast(
                                  //     msg: deleteViewModel.error ??
                                  //         "Failed to delete",
                                  //     backgroundColor: Colors.red,
                                  //   );
                                  //   }
                                },
                                child: const Text(
                                  "Deselect",
                                  style: TextStyle(color: AppColors.black),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((value) => value ?? false);
  }

  static Future<bool> showOTPdialog(BuildContext context, String email) async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            String otpCode = "";
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Icon(Icons.password,
                                    size: 50, color: AppColors.green),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomInkWellItem3(
                                    imagePath: Icons.close_sharp,
                                    color: AppColors.green,
                                    onTap: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            children: [
                              Text("Enter OTP sent to ${email}"),
                              const SizedBox(height: 20),
                              PinCodeTextField(
                                appContext: context,
                                length: 8,
                                onChanged: (value) => otpCode = value,
                                onCompleted: (value) => otpCode = value,
                                keyboardType: TextInputType.text,
                                autoFocus: true,
                                pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(5),
                                  fieldHeight: 35,
                                  fieldWidth: 25,
                                  activeColor: AppColors.green2,
                                  selectedColor: AppColors.green,
                                  inactiveColor: AppColors.black,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text(
                                        "Verify otp",
                                        style:
                                            TextStyle(color: AppColors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ) ??
        false;
  }
}
