import '../../domain/entities/MacAddressEntity.dart';

class MacAddressModel extends MacAddressEntity {
  MacAddressModel({
    required super.macAddress,
    required super.inverterName,
    required super.inverterPower,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      'macAddress': macAddress,
      'inverter_name': inverterName,
      'inverter_power': inverterPower,
    };
  }
}
