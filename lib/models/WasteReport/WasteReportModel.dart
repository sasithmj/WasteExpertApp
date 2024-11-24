import 'dart:convert';

class WasteReportModel {
  final String id;
  final String userId;
  final String? photo; // Nullable String for photo
  final double locationLat;
  final double locationLng;
  final DateTime reportDate;
  final String description;
  final List<String> wasteTypes;

  WasteReportModel({
    required this.id,
    required this.userId,
    this.photo,
    required this.locationLat,
    required this.locationLng,
    required this.reportDate,
    required this.description,
    required this.wasteTypes,
  });

  // Factory constructor to create a WasteReportModel from JSON
  factory WasteReportModel.fromJson(Map<String, dynamic> json) {
    return WasteReportModel(
      id: json['_id'] as String,
      userId: json['UserId'] as String,
      // Check if 'Photo' exists and is not null before attempting to encode it
      photo: json['Photo'],
      locationLat: (json['locationLat'] as num).toDouble(),
      locationLng: (json['locationLng'] as num).toDouble(),
      reportDate: DateTime.parse(json['ReportDate'] as String),
      description: json['Description'] as String,
      wasteTypes: List<String>.from(json['WasteTypes']),
    );
  }

  // Method to convert a WasteReportModel instance to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'UserId': userId,
      // Encode the photo if it's not null, otherwise store null
      'Photo': photo,
      'locationLat': locationLat,
      'locationLng': locationLng,
      'ReportDate': reportDate.toIso8601String(),
      'Description': description,
      'WasteTypes': wasteTypes,
    };
  }
}
