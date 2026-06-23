import '../../domain/entities/UserModel.dart';

class DeviceModel {
  final int id;
  final String macAddress;
  final String? invertername;
  final int inverterPower;
  final UserModel user;

  DeviceModel(
      {required this.id,
      required this.macAddress,
      required this.invertername,
      required this.inverterPower,
      required this.user});

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: (json['id'] as int?) ?? 0,
      macAddress: json['mac_address'] ?? '00:00:00:00:00',
      invertername: json['inverter_name'] ?? 'unknown',
      inverterPower: json['inverter_power'] ?? 'unknown',
      user: json['user'] != null
          ? UserModel.fromJson(json['user'])
          : UserModel.defaultUser(),
    );
  }
}
