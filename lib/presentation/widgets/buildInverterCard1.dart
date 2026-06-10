import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/PiMembershipGrowthChart.dart';
import '../../../app/App_Colors.dart';
import '../../data/models/DeviceModel.dart';
import '../../data/models/inverter_data_model.dart';

class buildInverterCard1 extends StatelessWidget {
  // final List<InverterDataModel> dataoverall;
  // final String energydata;
  // final String endate;
  // final String entime;
  final InverterDataModel data;
  // final String date;
  // final String time;
  // final String deviceName;
  // final DeviceModel device;

  const buildInverterCard1({
    Key? key,
    // required this.dataoverall,
    // required this.energydata,
    // required this.endate,
    // required this.entime,
    required this.data,
    // required this.date,
    // required this.time,
    // required this.deviceName,
    // required this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Card(
            color: AppColors.card,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset("assets/inverter1.png", height: 40, width: 40),
                  const SizedBox(height: 10),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   mainAxisSize: MainAxisSize.max,
                  //   children: [
                  //     Expanded(
                  //       flex: 2,
                  //       child: Text("${device.invertername}",
                  //           style: const TextStyle(
                  //               color: AppColors.white, fontSize: 14)),
                  //     ),
                  //     const Expanded(
                  //       flex: 3,
                  //       child: Text("Power Usage",
                  //           style: TextStyle(
                  //               color: AppColors.white, fontSize: 13)),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 3),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   mainAxisSize: MainAxisSize.max,
                  //   children: [
                  //     Expanded(
                  //       flex: 2,
                  //       child: Text(deviceName,
                  //           style: const TextStyle(
                  //               color: AppColors.white, fontSize: 19)),
                  //     ),
                  //     Expanded(
                  //       flex: 3,
                  //       child: Text(
                  //           "${((double.tryParse("${data.genPower}") ?? 0) / 5 * 100).toStringAsFixed(1)} %",
                  //           style: TextStyle(
                  //               color: AppColors.gray2, fontSize: 14)),
                  //     ),
                  //   ],
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text("${data.genPower} kW",
                            style: const TextStyle(
                                color: AppColors.gray2, fontSize: 16)),
                      ),
                      Expanded(
                        flex: 3,
                        child: LinearProgressIndicator(
                          value: (double.tryParse("${data.genPower}") ?? 0) / 5,
                          backgroundColor: AppColors.white, // Background color
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.green), // Fill color
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 80),
          child: Card(
            color: AppColors.card,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Electricity Generated by Solar",
                      style: TextStyle(color: AppColors.white, fontSize: 14)),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${data.energyConsumed} kWh",
                          style:
                              TextStyle(color: AppColors.white, fontSize: 16)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: Colors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text("Live",
                              style: TextStyle(
                                  color: AppColors.white, fontSize: 14)),
                        ],
                      )
                    ],
                  ),
                  // Text("$date  $time",
                  //     style: TextStyle(color: AppColors.white, fontSize: 16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Units Consumed:",
                          style:
                              TextStyle(color: AppColors.white, fontSize: 16)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Solar Voltage:",
                          style:
                              TextStyle(color: AppColors.white, fontSize: 16)),
                      Text("${data.pvVoltage} VDC",
                          style:
                              TextStyle(color: AppColors.white, fontSize: 16)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Output Voltage:",
                          style:
                              TextStyle(color: AppColors.white, fontSize: 16)),
                      Text("${data.outputVoltage} VAC",
                          style:
                              TextStyle(color: AppColors.white, fontSize: 16)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Output Current:",
                          style:
                              TextStyle(color: AppColors.white, fontSize: 16)),
                      Text("${data.outputCurrent} A",
                          style:
                              TextStyle(color: AppColors.white, fontSize: 16)),
                    ],
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text("Error:",
                  //         style:
                  //             TextStyle(color: AppColors.white, fontSize: 16)),
                  //     Text("${data.error}",
                  //         style:
                  //             TextStyle(color: AppColors.white, fontSize: 16)),
                  //   ],
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("MAC:",
                          style:
                              TextStyle(color: AppColors.white, fontSize: 16)),
                      Text(data.macAddress,
                          style:
                              TextStyle(color: AppColors.white, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
