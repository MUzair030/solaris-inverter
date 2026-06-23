import 'package:flutter/material.dart';
import 'package:threepol_inverter_flutter/app/App_Colors.dart';
import 'package:threepol_inverter_flutter/data/models/inverter_data_model.dart';

class InverterItem extends StatelessWidget {
  final InverterDataModel inverter;

  const InverterItem({Key? key, required this.inverter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(inverter.deviceName),
        subtitle: Text(
          'Energy: ${inverter.energyConsumed} kWh',
          style: TextStyle(color: AppColors.black),
        ),
      ),
    );
  }
}
