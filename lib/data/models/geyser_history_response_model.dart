import '../../domain/entities/geyser_history_data_entity.dart';

class GeyserHistoryResponseModel
// extends GeyserHistoryDataEntity
{
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

  GeyserHistoryResponseModel({
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
  // GeyserHistoryResponseModel({
  //   required int id,
  //   required double energyConsumed,
  //   required double genPower,
  //   required double pvVoltage,
  //   required double outputVoltage,
  //   required double outputCurrent,
  //   required String macAddress,
  //   required int error,
  //   required String deviceName,
  //   required String version,
  //   required DateTime createdAt,
  // }) : super(
  //         id: id,
  //         energyConsumed: energyConsumed,
  //         genPower: genPower,
  //         pvVoltage: pvVoltage,
  //         outputVoltage: outputVoltage,
  //         outputCurrent: outputCurrent,
  //         macAddress: macAddress,
  //         error: error,
  //         deviceName: deviceName,
  //         version: version,
  //         createdAt: createdAt,
  //       );

  // factory GeyserHistoryResponseModel.fromJson(Map<String, dynamic> json) {
  //   return GeyserHistoryResponseModel(
  //     id: json['id'] ?? 0,
  //     energyConsumed: (json['energy_consumed'] as num?)?.toDouble() ?? 0.0,
  //     genPower: (json['gen_power'] as num?)?.toDouble() ?? 0.0,
  //     pvVoltage: (json['pv_voltage'] as num?)?.toDouble() ?? 0.0,
  //     outputVoltage: (json['output_voltage'] as num?)?.toDouble() ?? 0.0,
  //     outputCurrent: (json['output_current'] as num?)?.toDouble() ?? 0.0,
  //     macAddress: json['mac_address'] ?? '',
  //     error: json['error'] ?? 0,
  //     deviceName: json['device_name'] ?? '',
  //     version: json['version'] ?? '',
  //     createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
  //   );
  // }
  factory GeyserHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return GeyserHistoryResponseModel(
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
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'energy_consumed': energyConsumed,
  //     'gen_power': genPower,
  //     'pv_voltage': pvVoltage,
  //     'output_voltage': outputVoltage,
  //     'output_current': outputCurrent,
  //     'mac_address': macAddress,
  //     'error': error,
  //     'device_name': deviceName,
  //     'version': version,
  //     'createdAt': createdAt.toIso8601String(),
  //   };
  // }

  // static List<GeyserHistoryResponseModel> fromJsonList(List<dynamic> jsonList) {
  //   return jsonList.map((e) => GeyserHistoryResponseModel.fromJson(e)).toList();
  // }
}
