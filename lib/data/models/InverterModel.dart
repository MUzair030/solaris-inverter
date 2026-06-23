import '../../domain/entities/inverter_data.dart';

class InverterModel extends InverterEntity {
  const InverterModel({
    required int id,
    required double energyConsumed,
    required double genPower,
    required double pvVoltage,
    required double outputVoltage,
    required double outputCurrent,
    required String macAddress,
    required int error,
    required String deviceName,
    required String version,
    required DateTime createdAt,
  }) : super(
          id: id,
          energyConsumed: energyConsumed,
          genPower: genPower,
          pvVoltage: pvVoltage,
          outputVoltage: outputVoltage,
          outputCurrent: outputCurrent,
          macAddress: macAddress,
          error: error,
          deviceName: deviceName,
          version: version,
          createdAt: createdAt,
        );

  factory InverterModel.fromJson(Map<String, dynamic> json) {
    return InverterModel(
      id: json['id'],
      energyConsumed: json['energy_consumed'].toDouble(),
      genPower: json['gen_power'].toDouble(),
      pvVoltage: json['pv_voltage'].toDouble(),
      outputVoltage: json['output_voltage'].toDouble(),
      outputCurrent: json['output_current'].toDouble(),
      macAddress: json['mac_address'],
      error: json['error'],
      deviceName: json['device_name'],
      version: json['version'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
