class GeyserHistoryRequestModel {
  final String macAddress;
  final bool perday;
  final bool perweek;
  final bool permonth;
  final bool peryear;
  final bool completereport;

  GeyserHistoryRequestModel({
    required this.macAddress,
    this.perday = false,
    this.perweek = false,
    this.permonth = false,
    this.peryear = false,
    this.completereport = false,
  });

  Map<String, dynamic> toQueryParams() => {
        "macAddress": macAddress,
        "perday": perday.toString(),
        "perweek": perweek.toString(),
        "permonth": permonth.toString(),
        "peryear": peryear.toString(),
        "completereport": completereport.toString(),
      };
}
