/// A single aggregated bucket returned by the backend `/api/inverter/stats`
/// endpoint. Energy is summed per bucket; voltages/current/power are averaged.
class InverterStatsModel {
  final String bucket;
  final int count;
  final double energyConsumed;
  final double genPower;
  final double pvVoltage;
  final double outputVoltage;
  final double outputCurrent;

  const InverterStatsModel({
    required this.bucket,
    required this.count,
    required this.energyConsumed,
    required this.genPower,
    required this.pvVoltage,
    required this.outputVoltage,
    required this.outputCurrent,
  });

  factory InverterStatsModel.fromJson(Map<String, dynamic> json) {
    return InverterStatsModel(
      bucket: json["bucket"] ?? "",
      count: (json["count"] as num?)?.toInt() ?? 0,
      energyConsumed: ((json["energyConsumed"] ?? 0) as num).toDouble(),
      genPower: ((json["genPower"] ?? 0) as num).toDouble(),
      pvVoltage: ((json["pvVoltage"] ?? 0) as num).toDouble(),
      outputVoltage: ((json["outputVoltage"] ?? 0) as num).toDouble(),
      outputCurrent: ((json["outputCurrent"] ?? 0) as num).toDouble(),
    );
  }
}
