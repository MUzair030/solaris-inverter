/// A single aggregated bucket returned by the backend `/api/inverter/stats`
/// endpoint.
///
/// `energyDeltaKwh` is already a correct max-min delta computed server-side
/// for this bucket — it must never be re-derived by summing raw readings on
/// the client. `padded` marks a calendar slot the server zero-filled because
/// there were no real samples in it (used to keep charts continuous).
///
/// `solarEnergyDeltaKwh`, `gridEnergyDeltaKwh`, `avgSolarPowerKw`,
/// `avgOutputPowerKw`, `avgGridPowerKw` and `avgGridVoltage` are newer fields
/// fed by newer-firmware payloads. The server defaults every one of them to
/// `0.0` (never null) whenever they're not meaningful for a bucket — e.g. a
/// bucket whose only samples are old-firmware rows, or a padded bucket -
/// same non-null-double style as the existing fields above.
class InverterStatsBucket {
  final String bucket;
  final DateTime bucketStart;
  final int count;
  final double energyDeltaKwh;
  final double avgGenPowerKw;
  final double avgPvVoltage;
  final double avgOutputVoltage;
  final double avgOutputCurrent;
  final bool padded;
  final double solarEnergyDeltaKwh;
  final double gridEnergyDeltaKwh;
  final double avgSolarPowerKw;
  final double avgOutputPowerKw;
  final double avgGridPowerKw;
  final double avgGridVoltage;

  const InverterStatsBucket({
    required this.bucket,
    required this.bucketStart,
    required this.count,
    required this.energyDeltaKwh,
    required this.avgGenPowerKw,
    required this.avgPvVoltage,
    required this.avgOutputVoltage,
    required this.avgOutputCurrent,
    required this.padded,
    required this.solarEnergyDeltaKwh,
    required this.gridEnergyDeltaKwh,
    required this.avgSolarPowerKw,
    required this.avgOutputPowerKw,
    required this.avgGridPowerKw,
    required this.avgGridVoltage,
  });

  factory InverterStatsBucket.fromJson(Map<String, dynamic> json) {
    return InverterStatsBucket(
      bucket: json["bucket"] ?? "",
      bucketStart:
          DateTime.tryParse(json["bucketStart"] ?? "") ?? DateTime.now(),
      count: (json["count"] as num?)?.toInt() ?? 0,
      energyDeltaKwh: ((json["energyDeltaKwh"] ?? 0) as num).toDouble(),
      avgGenPowerKw: ((json["avgGenPowerKw"] ?? 0) as num).toDouble(),
      avgPvVoltage: ((json["avgPvVoltage"] ?? 0) as num).toDouble(),
      avgOutputVoltage: ((json["avgOutputVoltage"] ?? 0) as num).toDouble(),
      avgOutputCurrent: ((json["avgOutputCurrent"] ?? 0) as num).toDouble(),
      padded: (json["padded"] as bool?) ?? false,
      solarEnergyDeltaKwh:
          ((json["solarEnergyDeltaKwh"] ?? 0) as num).toDouble(),
      gridEnergyDeltaKwh:
          ((json["gridEnergyDeltaKwh"] ?? 0) as num).toDouble(),
      avgSolarPowerKw: ((json["avgSolarPowerKw"] ?? 0) as num).toDouble(),
      avgOutputPowerKw: ((json["avgOutputPowerKw"] ?? 0) as num).toDouble(),
      avgGridPowerKw: ((json["avgGridPowerKw"] ?? 0) as num).toDouble(),
      avgGridVoltage: ((json["avgGridVoltage"] ?? 0) as num).toDouble(),
    );
  }
}
