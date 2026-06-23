class InverterRequestModel {
  final String macAddress;
  final bool perday;
  final bool perweekl;
  final bool permonthy;
  final bool peryear;
  final bool completereport;

  InverterRequestModel({
    required this.macAddress,
    this.perday = false,
    this.perweekl = false,
    this.permonthy = false,
    this.peryear = false,
    this.completereport = false,
  });

  Map<String, dynamic> toJson() => {
        "macAddress": macAddress,
        "perday": perday,
        "perweekl": perweekl,
        "permonthy": permonthy,
        "peryear": peryear,
        "completereport": completereport,
      };
  // Check if at least one filter is true
  bool get hasAnyFilter =>
      perday || perweekl || permonthy || peryear || completereport;
}
