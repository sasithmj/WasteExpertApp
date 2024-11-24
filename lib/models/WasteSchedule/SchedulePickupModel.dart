// import 'package:flutter/foundation.dart';

class SchedulePickup {
  final String id;
  final String area;
  final DateTime date;
  final String collector;
  final String status;
  final List<LocationEntry> locations;
  final Map<String, int> quantity;

  SchedulePickup({
    required this.id,
    required this.area,
    required this.date,
    required this.collector,
    required this.status,
    required this.locations,
    required this.quantity,
  });

  factory SchedulePickup.fromJson(Map<String, dynamic> json) {
    return SchedulePickup(
      id: json['_id'],
      area: json['area'],
      date: DateTime.parse(json['date']),
      collector: json['collector'],
      status: json['status'],
      locations: (json['locations'] as List)
          .map((location) => LocationEntry.fromJson(location))
          .toList(),
      quantity: Map<String, int>.from(json['quantity']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'area': area,
      'date': date.toIso8601String(),
      'collector': collector,
      'status': status,
      'locations': locations.map((location) => location.toJson()).toList(),
      'quantity': quantity,
    };
  }
}

class LocationEntry {
  final String userId;
  final List<WasteType> wasteTypes;
  final DateTime scheduledDate;
  final String scheduleState;
  final Location location;
  final String id;

  LocationEntry({
    required this.userId,
    required this.wasteTypes,
    required this.scheduledDate,
    required this.scheduleState,
    required this.location,
    required this.id,
  });

  factory LocationEntry.fromJson(Map<String, dynamic> json) {
    return LocationEntry(
      userId: json['UserId'],
      wasteTypes: (json['WasteType'] as List)
          .map((waste) => WasteType.fromJson(waste))
          .toList(),
      scheduledDate: DateTime.parse(json['ScheduledDate']),
      scheduleState: json['ScheduleState'],
      location: Location.fromJson(json['location']),
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'WasteType': wasteTypes.map((waste) => waste.toJson()).toList(),
      'ScheduledDate': scheduledDate.toIso8601String(),
      'ScheduleState': scheduleState,
      'location': location.toJson(),
      'id': id,
    };
  }
}

class WasteType {
  final String wasteType;
  final int quantity;

  WasteType({
    required this.wasteType,
    required this.quantity,
  });

  factory WasteType.fromJson(Map<String, dynamic> json) {
    return WasteType(
      wasteType: json['wastetype'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wastetype': wasteType,
      'quantity': quantity,
    };
  }
}

class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat'],
      lng: json['lng'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}
