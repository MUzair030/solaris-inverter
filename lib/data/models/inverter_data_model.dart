class InverterDataModel {
  final int id;
  final double energyConsumed;
  final double genPower;
  final double pvVoltage;
  final double outputVoltage;
  final double outputCurrent;
  final String macAddress;

  /// Absent (`null`) for newer-firmware rows - that payload has no error
  /// code, device name or version fields at all. Never guaranteed non-null
  /// for any device anymore.
  final int? error;
  final String? deviceName;
  final String? version;

  final DateTime createdAt;

  /// Genuine PV-only power (kW) - only present on newer-firmware payloads.
  /// Null for old-firmware rows; callers should fall back to [genPower]
  /// (which historically meant total output power, not solar-only).
  final double? solarPower;

  /// Cumulative solar energy generated (kWh), a real separate meter. Null
  /// for old-firmware rows.
  final double? solarUnits;

  /// Real measured total load power (kW) - only present on newer-firmware
  /// payloads. Null for old-firmware rows; callers should fall back to the
  /// `outputVoltage * outputCurrent / 1000` estimate.
  final double? outputPower;

  /// Grid voltage (V). Null for old-firmware rows.
  final double? gridVoltage;

  /// Grid contribution power (kW). Sign indicates direction: positive =
  /// importing from the grid, negative = exporting to the grid (inferred
  /// from hardware sample physics, not yet confirmed by the hardware team).
  /// Null for old-firmware rows.
  final double? gridPower;

  /// Cumulative grid import energy (kWh), a real separate meter. Null for
  /// old-firmware rows.
  final double? gridUnits;

  /// Firmware-reported device type. Null for old-firmware rows.
  final int? deviceType;

  InverterDataModel({
    required this.id,
    required this.energyConsumed,
    required this.genPower,
    required this.pvVoltage,
    required this.outputVoltage,
    required this.outputCurrent,
    required this.macAddress,
    this.error,
    this.deviceName,
    this.version,
    required this.createdAt,
    this.solarPower,
    this.solarUnits,
    this.outputPower,
    this.gridVoltage,
    this.gridPower,
    this.gridUnits,
    this.deviceType,
  });

  factory InverterDataModel.fromJson(Map<String, dynamic> json) {
    return InverterDataModel(
      id: json["id"] as int,
      // These 5 fields stay required/non-null - the backend contract
      // guarantees them populated for both old- and new-firmware rows - but
      // still use explicit `num` casts (rather than a blind `.toDouble()`)
      // so the expected JSON type is documented, not just assumed.
      energyConsumed: (json["energy_consumed"] as num).toDouble(),
      genPower: (json["gen_power"] as num).toDouble(),
      pvVoltage: (json["pv_voltage"] as num).toDouble(),
      outputVoltage: (json["output_voltage"] as num).toDouble(),
      outputCurrent: (json["output_current"] as num).toDouble(),
      macAddress: json["mac_address"] as String,
      // Absent (null) on newer-firmware rows - never blindly cast.
      error: json["error"] as int?,
      deviceName: json["device_name"] as String?,
      version: json["version"] as String?,
      createdAt: DateTime.parse(json["createdAt"]),
      // New fields - null for old-firmware rows, never fabricated.
      solarPower: (json["solar_power"] as num?)?.toDouble(),
      solarUnits: (json["solar_units"] as num?)?.toDouble(),
      outputPower: (json["output_power"] as num?)?.toDouble(),
      gridVoltage: (json["grid_voltage"] as num?)?.toDouble(),
      gridPower: (json["grid_power"] as num?)?.toDouble(),
      gridUnits: (json["grid_units"] as num?)?.toDouble(),
      deviceType: json["device_type"] as int?,
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
      'solar_power': solarPower,
      'solar_units': solarUnits,
      'output_power': outputPower,
      'grid_voltage': gridVoltage,
      'grid_power': gridPower,
      'grid_units': gridUnits,
      'device_type': deviceType,
    };
  }
}
