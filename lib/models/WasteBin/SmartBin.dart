class SmartBin {
  final String id;
  final String area;
  final double locationLat;
  final double locationLng;
  final String garbageTypes;
  final String fillLevel;
  final int version;

  SmartBin({
    required this.id,
    required this.area,
    required this.locationLat,
    required this.locationLng,
    required this.garbageTypes,
    required this.fillLevel,
    required this.version,
  });

  factory SmartBin.fromJson(Map<String, dynamic> json) {
    return SmartBin(
      id: json['id'] ?? '',
      area: json['area'] ?? 'Unknown',
      locationLat: json['locationLat']?.toDouble() ?? 0.0,
      locationLng: json['locationLng']?.toDouble() ?? 0.0,
      garbageTypes: json['garbageTypes'] ?? 'Unknown',
      fillLevel: json['fillLevel'] ?? 'Unknown',
      version: json['__v'] ?? 0,
    );
  }
}

class BinResponse {
  final bool status;
  final List<SmartBin> bins;

  BinResponse({
    required this.status,
    required this.bins,
  });

  factory BinResponse.fromJson(Map<String, dynamic> json) {
    var list = json['bins'] as List;
    List<SmartBin> binList = list.map((i) => SmartBin.fromJson(i)).toList();

    return BinResponse(
      status: json['status'] ?? false,
      bins: binList,
    );
  }
}
