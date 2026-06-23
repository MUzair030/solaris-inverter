class InverterResponseModel {
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

  InverterResponseModel({
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

  factory InverterResponseModel.fromJson(Map<String, dynamic> json) {
    return InverterResponseModel(
      id: json["id"] ?? 0,
      energyConsumed: (json["energy_consumed"] ?? 0).toDouble(),
      genPower: (json["gen_power"] ?? 0).toDouble(),
      pvVoltage: (json["pv_voltage"] ?? 0).toDouble(),
      outputVoltage: (json["output_voltage"] ?? 0).toDouble(),
      outputCurrent: (json["output_current"] ?? 0).toDouble(),
      macAddress: json["mac_address"] ?? "",
      error: json["error"] ?? 0,
      deviceName: json["device_name"] ?? "",
      version: json["version"] ?? "",
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}
