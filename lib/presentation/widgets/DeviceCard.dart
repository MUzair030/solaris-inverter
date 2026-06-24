import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:threepol_inverter_flutter/app/App_Colors.dart';

import '../../data/models/DeviceModel.dart';

class DeviceCard extends StatefulWidget {
  final DeviceModel device;
  final bool isSelected;
  final String deviceName;

  DeviceCard(
      {Key? key,
      required this.device,
      required this.isSelected,
      required this.deviceName})
      : super(key: key);

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    print("object: ${widget.device.macAddress}");
    return Card(
      color: widget.isSelected
          ? AppColors.lightgreen.withOpacity(0.6)
          : AppColors.blue,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset("assets/inverter1.png",
                          height: 50, width: 50),
                      // Transform.scale(
                      //   scale: 0.7,
                      //   child: CupertinoSwitch(
                      //     value: isSwitched,
                      //     activeColor: AppColors.blue,
                      //     trackColor: AppColors.switchgray,
                      //     onChanged: (value) {
                      //       setState(
                      //         () {
                      //           isSwitched = value;
                      //           if (isSwitched) {
                      //             Fluttertoast.showToast(msg: "added to favorite");
                      //           }
                      //         },
                      //       );
                      //     },
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(right: 10.0),
                      //   child: Row(
                      //     children: [
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Row(
                        children: [
                          Text(widget.device.invertername!,
                              style: const TextStyle(
                                  color: AppColors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.deviceName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                  fontSize: 12)),
                          Text("${widget.device.inverterPower} KVA",
                              style: const TextStyle(
                                  color: AppColors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text("${widget.device.macAddress}",
                          style: const TextStyle(
                              color: AppColors.white, fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.isSelected)
            const Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 25),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
