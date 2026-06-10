import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/ErrorScreen.dart';
import '../../../app/App_Colors.dart';
import '../../data/models/inverter_data_model.dart';
import '../viewmodels/inverter_viewmodel.dart';
import 'LegendItem.dart';
import 'MultiLineChartWidget.dart';
import 'PowerTrendChartWidget.dart';
import 'SingleDayChart.dart';

class buildInverterCard extends StatefulWidget {
  final List<InverterDataModel> dataoverall;
  final String energydata;
  final String endate;
  final String entime;
  final InverterDataModel data;
  final String date;
  final String time;
  final String deviceName;
  // final DeviceModel device;
  final String devicename;
  final int storedPower;

  const buildInverterCard({
    Key? key,
    required this.dataoverall,
    required this.energydata,
    required this.endate,
    required this.entime,
    required this.data,
    required this.date,
    required this.time,
    required this.deviceName,
    // required this.device,
    required this.devicename,
    required this.storedPower,
  }) : super(key: key);

  @override
  State<buildInverterCard> createState() => _buildInverterCardState();
}

class _buildInverterCardState extends State<buildInverterCard> {
  bool isExpanded = true;

  // InverterDataModel getLatestInverterData(List<InverterDataModel> data) {
  //   data.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // latest first
  //   return data.first;
  // }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InverterViewModel>();
    final status = viewModel.status;
    final errorMessage = viewModel.errorTypeMessage;
    // final latest = getLatestInverterData(widget.dataoverall);

    // Fluttertoast.showToast(msg: "${widget.devicename}");

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, right: 5, left: 8, bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset("assets/inverter1.png",
                              height: 40, width: 40),
                          const SizedBox(width: 12),
                          if (!isExpanded)
                            Text(
                              widget.devicename,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                if (isExpanded) ...[
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 15, left: 15, bottom: 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                widget.devicename,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Expanded(
                              flex: 3,
                              child: Text("Power Usage",
                                  style: TextStyle(
                                      color: AppColors.white, fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              // child: Text("${widget.data.genPower} kW",
                              child: Text("${widget.storedPower} KVA",
                                  style: const TextStyle(
                                      color: AppColors.gray2, fontSize: 16)),
                            ),
                            Expanded(
                              flex: 3,
                              child: Builder(
                                builder: (context) {
                                  final genPower = double.tryParse(
                                          "${widget.data.genPower}") ??
                                      0;
                                  final storedPower = widget.storedPower;

                                  String percentageText = "0.0 %";

                                  if (storedPower > 0) {
                                    final percentage =
                                        (genPower / storedPower) * 100;
                                    if (percentage.isFinite) {
                                      percentageText =
                                          "${percentage.toStringAsFixed(1)} %";
                                    }
                                  }

                                  return Text(
                                    percentageText,
                                    style: const TextStyle(
                                      color: AppColors.gray2,
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(widget.deviceName,
                                  style: const TextStyle(
                                      color: AppColors.white, fontSize: 15)),
                            ),
                            Expanded(
                              flex: 3,
                              child: Builder(
                                builder: (context) {
                                  final genPower = double.tryParse(
                                          "${widget.data.genPower}") ??
                                      0;
                                  final storedPower = widget.storedPower;

                                  double progress = 0;

                                  if (storedPower > 0) {
                                    progress = genPower / storedPower;
                                  }

                                  // Prevent NaN or infinite values
                                  if (!progress.isFinite || progress.isNaN) {
                                    progress = 0;
                                  }

                                  return LinearProgressIndicator(
                                    value: progress.clamp(
                                        0.0, 1.0), // Keep value between 0 and 1
                                    backgroundColor: AppColors.white,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            AppColors.green),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
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
              padding: const EdgeInsets.only(top: 15, bottom: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text("Electricity Generated by Solar",
                        style: TextStyle(color: AppColors.white, fontSize: 14)),
                  ),
                  viewModel.errorTypeMessage != null &&
                          viewModel.errorTypeMessage != "Device Stable" &&
                          widget.devicename != "Unknown"
                      ? ErrorScreen(
                          error: viewModel.errorTypeMessage,
                          status: status,
                        )
                      : Column(
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${widget.data.energyConsumed} kWh",
                                      style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 16)),
                                  widget.devicename == "Unknown"
                                      ? const Column(
                                          children: [],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    color: status == "Online"
                                                        ? const Color(0xFF2277BB)
                                                        : Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  status,
                                                  style: TextStyle(
                                                    color: status == "Online"
                                                        ? const Color(0xFF2277BB)
                                                        : Colors.red,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text.rich(
                                              TextSpan(
                                                text: viewModel
                                                        .errorTypeMessage ??
                                                    'Loading...',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: AppColors.green,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Stack(
                              children: [
                                if (widget.dataoverall.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "No Data Available...",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: MultiLineChartWidget(
                                        // child: PowerTrendChartWidget(
                                        dataoverall: widget.dataoverall),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(widget.date,
                                      style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 16)),
                                  Text(widget.time,
                                      style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 16)),
                                ],
                              ),
                            ),
                          ],
                        ),
                  // const SizedBox(height: 30),
                  // Column(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     SizedBox(
                  //         height: 300,
                  //         child: SingleDayChart(dataList: widget.dataoverall)),
                  //     const SizedBox(height: 20),
                  //     buildLegend(),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
