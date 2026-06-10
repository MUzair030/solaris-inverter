import 'package:flutter/material.dart';

class SelectedDeviceProvider extends ChangeNotifier {
  String? mac;
  String? name;
  int? power;

  String? get getMac => mac;
  String? get getname => name;
  int? get getpower => power;

  void setDevice(String mac, String name, int power) {
    this.mac = mac;
    this.name = name;
    this.power = power;
    notifyListeners();
  }

  void clearDevice() {
    mac = null;
    name = null;
    power = null;
    notifyListeners();
  }
}
