class InverterDataModel {
  final int id;
  final double energyConsumed;
  final double genPower;
  final double pvVoltage;
  final double outputVoltage;
  final double outputCurrent;
  final String macAddress;
  final int error;
  final String deviceName;
  final String version;
  final DateTime createdAt;

  InverterDataModel({
    required this.id,
    required this.energyConsumed,
    required this.genPower,
    required this.pvVoltage,
    required this.outputVoltage,
    required this.outputCurrent,
    required this.macAddress,
    required this.error,
    required this.deviceName,
    required this.version,
    required this.createdAt,
  });

  factory InverterDataModel.fromJson(Map<String, dynamic> json) {
    return InverterDataModel(
      id: json["id"],
      energyConsumed: json["energy_consumed"].toDouble(),
      genPower: json["gen_power"].toDouble(),
      pvVoltage: json["pv_voltage"].toDouble(),
      outputVoltage: json["output_voltage"].toDouble(),
      outputCurrent: json["output_current"].toDouble(),
      macAddress: json["mac_address"],
      error: json["error"],
      deviceName: json["device_name"],
      version: json["version"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'energy_consumed': energyConsumed,
      'gen_power': genPower,
      'pv_voltage': pvVoltage,
      'output_voltage': outputVoltage,
      'output_current': outputCurrent,
      'mac_address': macAddress,
      'error': error,
      'device_name': deviceName,
      'version': version,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
